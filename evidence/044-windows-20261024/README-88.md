# MENU REACH development and rejected review, 24 October 2026 Eastern

PR141 source88cb77ab412ac2fda30734ddee5f12c448e86552 on base69fc9e46.
Independent review requests changes for one P2: mute a chosen master volume,
leave Settings, reopen and unmute, and the level returns to100%. This head
is not approved or merged. A newer repair is being verified separately.

proof-88.zip has50members:49 raw evidence files/images plus a per-file manifest.
Payload14232089bytes; ZIP4699702bytes.
SHA256:c100dbcc76946928825651ba023873ef0334ef39a2ad10766b042d6026d9ad1d.
Every member was reopened and its size/hash verified.

Fresh author88: core836/0, native menu297/0 including12 separately named PNG
writes, rules15/onboarding30/Back17/Challenges86 all0. Import1f8 is separately
named: identical production to88, whose only change was the test. Fresh reviewer88:
import, core836, menu headless/native285 each, home headless/native1472 each,
native frontend63/accessibility88/density-menu7/density-scroll17/camera68,
rules15/Back17/onboarding30, all0 and exit0. Registry255 validates0/0.
Root inspected four representative native captures; no layout overlaps observed.
These successful tests did not cover the mute reopening defect until review.

Reviewer final88-mute-reopen.log independently reproduces35%->mute0->close->
reopen restore100%->unmute100%. A new real-touch regression, run against88
production with the added test, gives291/3 RED across the three shapes. Its
mute-reopen-red.log is retained. A later fix log is deliberately excluded here.

Earlier failures remain historical, not acceptance evidence. Baseline126/39
includes the real missing settings/navigation controls and fixture mistakes:
the first erase check occurred after Back, and the960 fixture initially used
the density subclass. These were corrected before green. Candidate225/6 compared
the complete archive against old audio settings; diagnostics prove only chosen
music/effects compatibility mirrors changed through the existing Android Back
autosave. The corrected new test compares every other archive field exactly
and requires audio mirrors match the deliberately chosen settings. Existing
accessibility88/2 exposed reopening from stale persisted rather than live
settings; the source fix reran88/0 with the original assertion retained. The
existing test now explicitly waits for the shared300ms debounce before reading.
Older candidate264/core836/home1472 results remain attributed by log filename.

final88-mute-probe.log is an unsuccessful supplemental launcher invocation,
not a product test. A malformed Raw invocation launched isolated main; the
reviewer identified/stopped only its isolated processes after about39seconds.
The wrapper misleadingly reports a480second timeout. The subsequent correctly
launched final88-mute-reopen.log is the actual defect reproduction, exit0.

All paths are isolated test fixtures. No personal save directories, secrets,
APKs or phone runs are included. Native PNGs are engine captures, not physical
Android ergonomics or complete campaign/fork evidence. No full local matrix.
