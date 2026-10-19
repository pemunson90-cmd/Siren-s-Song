# Model assignments and observable usage

User policy: Astra kickoff/rare justified escalation; Sol 6.1 production, criticism, testing and all subagents. No premium fan-out. Exact billing/token totals are not exposed by current tools.

| Task | Requested routing | Observed routing evidence | Result |
| --- | --- | --- | --- |
| Architecture kickoff/coordinator | User requested Astra | Runtime tools do not expose root model ID or usage; no model change tool exists | Corpus, visual references, ADR, production architecture/plan |
| sol_environment_audit | `gpt-6.1-sol`, `fork_turns=none`, medium reasoning | Explicit supported model argument accepted; returned task `/root/sol_environment_audit`; backend attestation unavailable | Existing environment audit, official templates, Android/desktop tooling and CI |
| sol_production_lead | `gpt-6.1-sol`, `fork_turns=none`, high reasoning | Explicit supported model argument accepted; task `/root/sol_production_lead`; backend attestation/usage unavailable | Sustained production owner |

Do not translate a requested model ID into an unsupported claim about measured execution or cost savings. Record each critic/exception here. No Astra subagents or premium escalations have been requested. Keep concurrency to production+tooling, and a fresh critic only when needed.

| sol_evidence_critic (baseline) | `gpt-6.1-sol`, `fork_turns=none`, high reasoning | Supported explicit argument accepted; task `/root/sol_production_lead/sol_evidence_critic`; actual backend/usage unavailable | Raw images/references inspected before claims; independent review in progress |

Baseline critic completed its report and independently reran55core/139runtime follow-up tests after attention fixes. No new delegates or escalations. Current52core count reflects fewer sampled path waypoints after smoothing, not removed invariant tests;139runtime remains.
