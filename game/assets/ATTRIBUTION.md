# Original production assets

All game drawing, noise materials, and procedural audio are original work produced for Siren's Song. No imported concept scene is used as a game background.

- `materials/basalt.png`: original image generation, 19 October 2026, generation `exec-eaed2649-5e2d-4ef0-bc74-0b37a60166a3`; seamless submerged basalt material, mapped onto collision/LOS terrain polygons.
- `craft/quietus.png`: original image generation `exec-0f0d1b8c-0fe8-4f93-8e41-50b2e7d0f215`, using the user-supplied Quietus exterior sheet as silhouette reference; transparent craft asset. Reference original remains byte-identical outside export tree.
- `structures/foundry.png`: original image generation `exec-3a2ef01c-53b5-440e-ae3c-607ec39e7c25`; transparent alien fabrication structure, separately placed in the interactive world.
- Ocean noise, basalt extrusion faces, drones, Siren geometry, routes, instrument drawings: authored GDScript in `src/presentation/ocean_view.gd`.
- All sound signals: original deterministic synthesis in `src/audio/soundscape.gd`; no external samples.
- Typeface: Godot's bundled fallback font; engine-distributed font licensing applies. Engine and export template attribution follows Godot's MIT license and bundled third-party notices.

Generated material fidelity and viewpoint continuity remain subject to the independent visual review and continued art direction.

- `craft/siren_ray.png`: original transparent sprite generation `exec-af79225c-9265-4868-b093-e263da9fe36d`, using the approved angular-ray study as design reference. Separate physical asset; beam/target/impact remain live simulation-driven overlays.
