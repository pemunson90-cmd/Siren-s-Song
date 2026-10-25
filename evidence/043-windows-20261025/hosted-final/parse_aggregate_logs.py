import hashlib
import json
import pathlib
import re
import zipfile


ROOT = pathlib.Path(__file__).resolve().parent
RUN_ID = 40223499332
ZIP_PATH = ROOT / f"{RUN_ID}-logs.zip"
MANIFEST_PATH = ROOT / "manifest.json"
SUMMARY = re.compile(rb"(?m)^(.*\bCHECKS)\s+(\d+)\s+FAILURES\s+(\d+)\s*$")
ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
TIMESTAMP = re.compile(r"^\d{4}-\d\d-\d\dT\S+Z\s*")
LEAK = re.compile(r"resources still in use|ObjectDB instances leaked", re.IGNORECASE)


def main():
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    with zipfile.ZipFile(ZIP_PATH) as archive:
        if archive.testzip() is not None:
            raise SystemExit("Stored logs ZIP failed CRC check.")
        member_names = set(archive.namelist())
        chosen = {"guidance": "1_guidance.txt", "game-smoke": "0_game-smoke.txt"}
        records = {}
        for job, member_name in chosen.items():
            if member_name not in member_names:
                raise SystemExit(f"Missing aggregate member for {job}.")
            raw = archive.read(member_name)
            decoded = raw.decode("utf-8", errors="replace")
            output = ROOT / f"{RUN_ID}-{job}-aggregate.log"
            output.write_bytes(decoded.encode("utf-8"))
            matches = SUMMARY.findall(raw)
            summaries = [{
                "label": TIMESTAMP.sub("", ANSI.sub("", label.decode("utf-8", errors="replace"))).strip(),
                "checks": int(checks), "failures": int(failures),
            } for label, checks, failures in matches]
            engine_lines = []
            for line in decoded.splitlines():
                clean = ANSI.sub("", line)
                clean = TIMESTAMP.sub("", clean).strip()
                if clean.startswith("SCRIPT ERROR:") or clean.startswith("ERROR:") or LEAK.search(clean):
                    engine_lines.append(clean)
            records[job] = {
                "path": str(output),
                "source_member_name": member_name,
                "source_member_bytes": len(raw),
                "source_member_sha256": hashlib.sha256(raw).hexdigest(),
                "decoded_bytes": len(decoded.encode("utf-8")),
                "decoded_sha256": hashlib.sha256(decoded.encode("utf-8")).hexdigest(),
                "summary_count": len(summaries),
                "summaries": summaries,
                "total_reported_checks": sum(item["checks"] for item in summaries),
                "total_reported_failures": sum(item["failures"] for item in summaries),
                "engine_error_or_leak_line_count": len(engine_lines),
                "engine_error_or_leak_lines": engine_lines,
            }
        manifest["aggregate_jobs"] = records
        manifest["aggregate_policy"] = "Parsed only the single top-level aggregate member for each job; job/step member files are retained and hashed in the ZIP inventory but excluded to avoid counting duplicated per-step summaries."
        MANIFEST_PATH.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(json.dumps({
            "manifest": str(MANIFEST_PATH),
            "jobs": {job: {
                "path": item["path"],
                "source_member": item["source_member_name"],
                "summary_count": item["summary_count"],
                "total_reported_checks": item["total_reported_checks"],
                "total_reported_failures": item["total_reported_failures"],
                "engine_error_or_leak_line_count": item["engine_error_or_leak_line_count"],
            } for job, item in records.items()},
            "final_module_summaries": [
                {"job": "game-smoke", "label": value["label"], "checks": value["checks"], "failures": value["failures"]}
                for value in records["game-smoke"]["summaries"]
                if value["label"] in {"SAVE2 STORAGE CHECKS", "SAVE2 FORKS CHECKS", "SAVE2 UI CHECKS"}
            ],
        }, indent=2))


if __name__ == "__main__":
    main()
