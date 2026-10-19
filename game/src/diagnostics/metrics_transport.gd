extends RefCounted
# Android's observed logger cuts a single payload at 1023 bytes. Keep all data,
# using bounded ASCII records over raw UTF8 chunks and full-snapshot integrity.
const RAW_CHUNK_BYTES=450
static func encode(snapshot: Dictionary,session: String,serial: int) -> Array:
 var payload=JSON.stringify(snapshot)
 var bytes=payload.to_utf8_buffer()
 var digest=payload.sha256_text()
 var count=ceili(float(bytes.size())/RAW_CHUNK_BYTES)
 var records=[]
 for part in count:
  var data=Marshalls.raw_to_base64(bytes.slice(part*RAW_CHUNK_BYTES,mini((part+1)*RAW_CHUNK_BYTES,bytes.size())))
  records.append("SS_UI_METRICS_PART id=%s:%d part=%d parts=%d bytes=%d sha256=%s data=%s"%[session,serial,part,count,bytes.size(),digest,data])
 return records
