# Passthrough-style simulation

The player scene automatically adds a full-screen effect to the XR camera. It
simulates a camera-like view of the **rendered virtual environment**; it does
not access or modify the Quest's real camera passthrough. This is an artistic
approximation, not a calibrated model of any Quest firmware or hardware.

Run the main scene on the headset. Use the right controller and B to interact
with the world-space control panel. The panel adjusts static warp, animated
swim, edge warp, softness, grain, and edge darkening. Use "Simulation enabled"
to compare with the unmodified view, and "Reset to Defaults" to restore the
sliders. The edge darkening suggests a restricted field of view; it does not
change the headset's optics or actual field of view.

The post-process reads Godot's 3D screen texture, which contains opaque scene
rendering rather than the real camera feed. Transparent objects and UI may not
receive the effect. The swim responds to camera rotation, not depth or
translation, and is also animated while stationary.

Test both eyes on the target headset and check frame rate and comfort. Reading
the screen texture can be expensive in XR, and the blur adds multiple texture
samples. Lowering an effect's slider does not eliminate the cost of the
full-screen pass; disabling the simulation removes the pass. Stop testing if
the effect causes discomfort.
