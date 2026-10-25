import hashlib
import io
import json
import pathlib
import re
import subprocess
import sys
import zipfile


GH = r"C:\Program Files\GitHub CLI\gh.exe"
REPO = "pemunson90-cmd/Siren-s-Song"
RUN_ID = 40223499332
EXPECTED_SHA = "080add0a1b357e7c9758b317cbdfaadcf20d3f1e"
EXPECTED_JOBS = {121259977835: "guidance", 121259978065: "game-smoke"}
SUMMARY = re.compile(rb"(?m)^.*CHECKS\s+(\d+)\s+FAILURES\s+(\d+).*$")
ENGINE = re.compile(rb"(?im)^.*(?:SCRIPT ERROR:|(?:^|\s)ERROR:|resources still in use|ObjectDB instances leaked).*$")


def call(args):
    return subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)


def main():
    root = pathlib.Path(sys.argv[1]).resolve()
    root.mkdir(parents=True, exist_ok=True)
    metadata_cmd = call([GH, "run", "view", str(RUN_ID), "--repo", REPO,
                         "--json", "databaseId,headSha,status,conclusion,url,workflowName,event,createdAt,updatedAt"])
    if metadata_cmd.returncode != 0:
        raise SystemExit("Run metadata unavailable; no retry performed.")
    metadata = json.loads(metadata_cmd.stdout.decode("utf-8"))
    jobs_cmd = call([GH, "api", f"/repos/{REPO}/actions/runs/{RUN_ID}/jobs?per_page=100"])
    if jobs_cmd.returncode != 0:
        raise SystemExit("Job metadata unavailable; no retry performed.")
    jobs_payload = json.loads(jobs_cmd.stdout.decode("utf-8"))
    jobs = jobs_payload.get("jobs", [])
    run_verified = (
        metadata.get("databaseId") == RUN_ID
        and metadata.get("headSha") == EXPECTED_SHA
        and metadata.get("status") == "completed"
        and metadata.get("conclusion") == "success"
    )
    job_records = []
    for job in jobs:
        job_records.append({
            "id": job.get("id"), "name": job.get("name"),
            "status": job.get("status"), "conclusion": job.get("conclusion"),
            "html_url": job.get("html_url"), "head_sha": job.get("head_sha"),
            "run_attempt": job.get("run_attempt"),
        })
    jobs_verified = all(
        any(job.get("id") == expected_id and job.get("name") == expected_name
            and job.get("status") == "completed" and job.get("conclusion") == "success"
            and job.get("head_sha") == EXPECTED_SHA for job in jobs)
        for expected_id, expected_name in EXPECTED_JOBS.items()
    )

    logs_cmd = call([GH, "api", f"/repos/{REPO}/actions/runs/{RUN_ID}/logs"])
    if logs_cmd.returncode != 0:
        manifest = {
            "run_metadata": metadata, "run_metadata_exit_code": metadata_cmd.returncode,
            "run_verified": run_verified, "jobs": job_records,
            "jobs_api_exit_code": jobs_cmd.returncode, "jobs_verified": jobs_verified,
            "log_archive_status": "unavailable_no_retry", "logs_api_exit_code": logs_cmd.returncode,
            "qualification": "Run success metadata does not substitute for an unavailable log archive.",
        }
        (root / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(json.dumps({"manifest": str(root / "manifest.json"), "log_archive_status": "unavailable_no_retry"}, indent=2))
        return

    zip_bytes = logs_cmd.stdout
    zip_path = root / f"{RUN_ID}-logs.zip"
    zip_path.write_bytes(zip_bytes)
    try:
        archive = zipfile.ZipFile(io.BytesIO(zip_bytes))
        bad_member = archive.testzip()
    except Exception:
        bad_member = "invalid zip"
        archive = None
    members = []
    aggregate_info = {}
    aggregate_bytes = {name: bytearray() for name in EXPECTED_JOBS.values()}
    if archive is not None and bad_member is None:
        for info in archive.infolist():
            if info.is_dir():
                continue
            raw = archive.read(info.filename)
            name = info.filename.lower()
            matched = [job_name for job_name in EXPECTED_JOBS.values() if job_name in name]
            members.append({
                "name": info.filename,
                "compressed_bytes": info.compress_size,
                "uncompressed_bytes": len(raw),
                "crc32": f"{info.CRC:08x}",
                "sha256": hashlib.sha256(raw).hexdigest(),
                "mapped_jobs": matched,
            })
            for job_name in matched:
                aggregate_bytes[job_name].extend(raw)

    aggregate_records = {}
    for job_name, raw_buffer in aggregate_bytes.items():
        raw = bytes(raw_buffer)
        decoded = raw.decode("utf-8", errors="replace")
        aggregate_path = root / f"{RUN_ID}-{job_name}-aggregate.log"
        aggregate_path.write_bytes(decoded.encode("utf-8"))
        summary_matches = SUMMARY.findall(raw)
        summaries = [{"checks": int(checks), "failures": int(failures)} for checks, failures in summary_matches]
        engine_lines = ENGINE.findall(raw)
        aggregate_records[job_name] = {
            "path": str(aggregate_path),
            "source_member_names": [item["name"] for item in members if job_name in item["mapped_jobs"]],
            "decoded_bytes": len(decoded.encode("utf-8")),
            "decoded_sha256": hashlib.sha256(decoded.encode("utf-8")).hexdigest(),
            "summary_count": len(summaries),
            "summaries": summaries,
            "numeric_failure_total": sum(item["failures"] for item in summaries),
            "engine_error_or_leak_line_count": len(engine_lines),
            "engine_error_or_leak_lines": [line.decode("utf-8", errors="replace") for line in engine_lines],
        }

    jobs_by_name = {job.get("name"): job for job in jobs}
    manifest = {
        "repository": REPO,
        "run_metadata": metadata,
        "run_metadata_exit_code": metadata_cmd.returncode,
        "run_verified_exact_head_completed_success": run_verified,
        "run_public_url": metadata.get("url"),
        "jobs_api_exit_code": jobs_cmd.returncode,
        "jobs_verified_expected_ids_completed_success": jobs_verified,
        "jobs": job_records,
        "log_archive_status": "downloaded_crc_valid" if archive is not None and bad_member is None else "invalid_zip_or_crc",
        "logs_api_exit_code": logs_cmd.returncode,
        "zip_path": str(zip_path),
        "zip_bytes": len(zip_bytes),
        "zip_sha256": hashlib.sha256(zip_bytes).hexdigest(),
        "zip_crc_check": "passed" if archive is not None and bad_member is None else "failed",
        "bad_member": bad_member,
        "zip_member_count": len(members),
        "zip_members": members,
        "aggregate_jobs": aggregate_records,
        "qualification": "Run metadata and both required jobs report success. Aggregated logs are parsed once per job. Summary counts are derived from aggregate log text, not inferred from suite registry ranks.",
    }
    manifest_path = root / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({
        "manifest": str(manifest_path), "run_verified": run_verified,
        "jobs_verified": jobs_verified, "zip_crc_check": manifest["zip_crc_check"],
        "zip_member_count": len(members), "zip_bytes": len(zip_bytes),
        "aggregates": {name: {"path": value["path"], "summary_count": value["summary_count"],
                              "numeric_failure_total": value["numeric_failure_total"],
                              "engine_error_or_leak_line_count": value["engine_error_or_leak_line_count"]}
                       for name, value in aggregate_records.items()},
    }, indent=2))


if __name__ == "__main__":
    main()
