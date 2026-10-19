"""Read complete metric snapshots across Android's short log-record boundary."""
import base64
import hashlib
import re

PART=re.compile(r'id=(\S{1,128}) part=(\d+) parts=(\d+) bytes=(\d+) sha256=([0-9a-f]{64}) data=([A-Za-z0-9+/=]+)')

def read_records(text):
    """Return (first-line position, full JSON or None) in snapshot-start order.

    None means that exact snapshot is incomplete. Callers must never fall back
    from an incomplete latest snapshot to an older complete one.
    """
    records=[]
    groups={}
    for position,line in enumerate(text.splitlines()):
        if 'SS_UI_METRICS_PART ' in line:
            match=PART.fullmatch(line.split('SS_UI_METRICS_PART ',1)[1])
            if not match:raise ValueError('Malformed metric part envelope')
            identity,index,count,length,digest,data=match.groups()
            index,count,length=map(int,(index,count,length))
            if not 1<=count<=512 or not 0<=index<count or not 1<=length<=450*count or count!=(length+449)//450:
                raise ValueError('Invalid metric part bounds')
            chunk=base64.b64decode(data,validate=True)
            expected=450 if index<count-1 else length-450*(count-1)
            if len(chunk)!=expected:raise ValueError('Metric part byte length mismatch')
            metadata=(count,length,digest)
            if identity not in groups:
                groups[identity]=(metadata,{},len(records))
                records.append((position,None))
            previous,chunks,record_index=groups[identity]
            if previous!=metadata:raise ValueError('Conflicting metric part metadata')
            if index in chunks:raise ValueError('Duplicate metric part')
            chunks[index]=chunk
            if len(chunks)==count:
                raw=b''.join(chunks[i] for i in range(count))
                if len(raw)!=length or hashlib.sha256(raw).hexdigest()!=digest:
                    raise ValueError('Metric snapshot length/hash mismatch')
                records[record_index]=(records[record_index][0],raw.decode('utf-8',errors='strict'))
        elif 'SS_UI_METRICS ' in line:
            records.append((position,line.split('SS_UI_METRICS ',1)[1]))
    return records
