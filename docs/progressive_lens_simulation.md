# Progressive-lens-inspired simulation

The effect is an illustrative screen-space warp inspired by the displacement
mapping in Stein et al., *Simulating Lens Distortion in Virtual Reality*
(2020). It is not the measured lens from that paper, a calibrated model, or
Quest camera passthrough. It affects the opaque rendered virtual scene;
transparent objects and UI may not be included.

The effect starts **off**. On the right controller, press **A** to show or
hide the panel; point at it and press **B** to interact. Use the simulation
button to turn the effect on or off. Strength is adjustable from 0.0 to 1.0
in steps of 0.1; reset restores 0.2. The panel remains at its initial position.
Bullets can pass through the panel.

Test both eyes and frame rate on the target headset. Stop if the effect causes
discomfort; exaggerated distortion may be disorienting.

The optical explanation, actual equations, and limitations are in
[progressive_lens_simulation.tex](progressive_lens_simulation.tex) and
[progressive_lens_simulation.pdf](progressive_lens_simulation.pdf).
To rebuild the PDF with a LaTeX distribution that includes `pdflatex`, run:

```powershell
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=docs docs\progressive_lens_simulation.tex
```
