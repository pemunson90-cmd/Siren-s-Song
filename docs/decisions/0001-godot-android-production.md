# ADR 0001 — Godot for native Android production

Status: accepted within the user's autonomous architectural grant, 18 October 2026.

The source corpus requires a 2D tactical simulation, independent drones, dynamic occlusion, layered world art, functional audio, touch planning and Android lifecycle support. Available environment probes found Godot 4.6.3 stable, JDK 17, Android SDK, Python, ffmpeg and Chromium. Matching export templates and a usable display were initially absent. No Android device/emulator/KVM was available.

Choose Godot 4.6.3 GDScript with Compatibility rendering and official matching Android templates. Use built-in 2D/UI/audio/navigation primitives; test simulation headlessly and capture real desktop output through a software display. Export debug-signed APKs using prebuilt templates before introducing Gradle plugins. Reuse the existing environment; do not publish a replacement.

Alternatives: native Kotlin/LibGDX fits existing Java/Android tools but adds bespoke scene/UI/render/editor tooling; HTML5/Canvas wrapper can reuse the monolithic prototypes but carries browser/lifecycle/performance constraints and weaker production asset tooling. Godot offers a stronger maintainable path to the complete game's art, sound and native mobile goals. MIT-licensed engine source and stable tagged export templates are the maintained upstream foundation: https://github.com/godotengine/godot and https://github.com/godotengine/godot-builds/releases/tag/4.6.3-stable .

Consequences: GDScript porting work is required; prototype rules and tests are references rather than a forced code translation. Matching official templates must be installed. Desktop captures do not validate device performance. Installation, actual touch, pause/resume under Android and performance remain explicit device validation gates. Revisit only if measured export/render/device blockers justify the migration cost.
