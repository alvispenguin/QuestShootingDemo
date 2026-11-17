# Passthrough-style simulation

The player scene automatically adds a full-screen effect to the XR camera. It
applies OpenCV's five-coefficient radial and tangential distortion model to the
**rendered virtual environment**; it does not access or modify the Quest's real
camera passthrough.

Run the main scene on the headset. Press A on the right controller to show or
hide the world-space control panel; it stays at its original position when
reopened. Drag the panel title bar with the pointer to move it in the view.
Aim at the panel and press B to interact with it. The panel exposes
OpenCV's five distortion coefficients: radial $k_1$, $k_2$, $k_3$ and
tangential $p_1$, $p_2$. Use the `<` and `>` buttons to adjust them, "Reset
Coefficients to Zero" to clear them, and "Simulation: ON/OFF" to compare with
the unmodified view. Coefficients default to zero because no camera calibration
data is included; use values calibrated for the camera and image geometry you
intend to model.

Each coefficient row has coarse adjustment buttons on the outside and fine
adjustment buttons beside the displayed value. For $k_1$, $p_1$, and $p_2$,
the steps are $0.1$ and $0.01$. For $k_2$ and $k_3$, they are $0.01$ and
$0.001$; the fine $k_3$ step is $0.0001$. The button labels show the applied
increment.

The post-process reads Godot's 3D screen texture, which contains opaque scene
rendering rather than the real camera feed. Transparent objects and UI may not
receive the effect. The shader numerically inverts OpenCV's forward distortion
model to find the source pixel for each output pixel. It is not a depth-
dependent or head-motion simulation, nor a Quest passthrough calibration.

Test both eyes on the target headset and check frame rate and comfort. Reading
the screen texture can be expensive in XR. Reducing the coefficient values does not
eliminate the cost of the full-screen pass; disabling the simulation removes
the pass. Stop testing if the effect causes discomfort.

## OpenCV camera calibration model

The shader's camera-coordinate mapping and Newton inverse are described in
[opencv_camera_calibration.tex](opencv_camera_calibration.tex), following the
[OpenCV calibration tutorial](https://github.com/opencv/opencv/blob/4.x/doc/py_tutorials/py_calib3d/py_calibration/py_calibration.markdown).
To compile the LaTeX source with a distribution that includes `pdflatex`, run
this from the repository root:

```powershell
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=docs docs\opencv_camera_calibration.tex
```

The output is `docs\opencv_camera_calibration.pdf`. Alternatively, compile the
`.tex` file in a LaTeX editor or Overleaf. The older
[passthrough simulation equations](passthrough_simulation_equations.tex) document
describes the previous custom warp and is retained for historical reference.
