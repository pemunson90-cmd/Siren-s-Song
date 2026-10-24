# 027 Windows evidence

Source730d45b, game tree984e155e, base aaff40e. All logged suites are area-specific;
no full scenario list ran locally. Import clean; core833, model92, journey10,
GPU wall42, old endings48, catalog199, route52/UI70, removal/save16, all zero failures.

Journeys use ordinary commands, actual threats and untouched bare craft. Operation30
won139.85s hull100;31won148.10s hull80.38. No teleportation, enemy removal,
bonus-photo requirement or free film. Separate model and wall fixtures control
positions and campaign state; they prove transitions/layout, not blind player skill.
Native OpenGL3.3 Compatibility on RTX2080Ti, Dummy audio, virtual420dpi,
cover2520x1080 and inner2184x1968. No physical-phone or headphone claims.

Removal probe ran in an isolated checkout of391ea97 (identical game source),
physically removing both ending selector and presenter before loading only the
SaveStore/Simulation dependency graph. Legacy, active30, active31 and completed
archives pass real checksummed disk round trips. Both modules were restored in
finally. This proves save compatibility, not full game boot with dangling hooks.
To disable: FinalPair.ENABLED=false restores the old ending display. To remove
presentation: remove the presenter/selector and their campaign-flow/debrief hooks;
retain final-pair catalog/factory/encounter definitions so existing saves stay valid.
No new saved fields. Old four endings and12/13 fork remain available.

Hashes and source identities are in manifest.json. Independent exact-head approval
is relayed in PR122. Hosted exact-head guidance/game-smoke remain the publication gate.
