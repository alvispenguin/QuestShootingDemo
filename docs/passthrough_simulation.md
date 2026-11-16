# Passthrough-style simulation

The player scene automatically adds a full-screen effect to the XR camera. It
simulates a camera-like view of the **rendered virtual environment**; it does
not access or modify the Quest's real camera passthrough. This is an artistic
approximation, not a calibrated model of any Quest firmware or hardware.

Run the main scene on the headset. Press A on the right controller to show or
hide the world-space control panel; it stays at its original position when
reopened. Aim at the panel and press B to interact with it. Use the `<` and `>`
buttons to adjust static warp strength (0.0 to 2.0, default 2.0) and edge warp
boost (0.0 to 3.0, default 1.4), both in 0.1 steps. Use "Simulation: ON/OFF"
to compare with the unmodified view, and "Reset to Defaults" to restore the
values. High warp can strongly distort the image near the edges.

The post-process reads Godot's 3D screen texture, which contains opaque scene
rendering rather than the real camera feed. Transparent objects and UI may not
receive the effect. This is static screen-space warping, not a depth-dependent
or head-motion simulation.

Test both eyes on the target headset and check frame rate and comfort. Reading
the screen texture can be expensive in XR. Lowering warp strength does not
eliminate the cost of the full-screen pass; disabling the simulation removes
the pass. Stop testing if the effect causes discomfort.

## Mathematical description

The standalone LaTeX source [passthrough_simulation_equations.tex](passthrough_simulation_equations.tex)
describes the shader equations. To compile it with a
LaTeX distribution that includes `pdflatex`, open PowerShell in the repository
root and run:

```powershell
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=docs docs\passthrough_simulation_equations.tex
```

The resulting PDF is `docs\passthrough_simulation_equations.pdf`. Alternatively,
open the `.tex` file in a LaTeX editor or Overleaf and compile it with pdfLaTeX.
