# Quest Shooting Demo

A Godot XR shooting demo for Meta Quest, with a passthrough-style visual
simulation applied to a virtual sci-fi environment. Shoot targets with either
controller and adjust the simulated camera effects using the in-world panel.

The effect is an artistic approximation applied to the **rendered virtual
scene**, not the Quest's real camera feed. It is not a calibrated model of
Quest passthrough.

## Requirements

- Godot 4.7.2; the project uses the Mobile renderer and Jolt Physics.
- A Meta Quest headset and controllers for standalone XR testing, or a
  compatible OpenXR headset and an active OpenXR runtime for desktop testing.
- For Quest deployment: Godot Android export templates, an Android SDK and
  Java development kit configured in Godot, and a headset configured for
  development and USB debugging.

Godot XR Tools and the Godot OpenXR Vendors extension are included in
[`addons/`](addons/). No separate addon download is needed.

## Open and run

1. Import [`project.godot`](project.godot) in Godot 4.7.2 and allow the
   resources to import.
2. Connect your headset and start its OpenXR runtime if testing from the
   desktop. OpenXR is enabled in the project settings.
3. Run the project with **F6** while [`main.tscn`](main.tscn) is open, or
   **F5** to launch the configured main scene.

The desktop preview alone does not verify how the effect looks in both eyes
or how it performs on the headset.

### Deploy to Quest

The project includes an Android export preset named `QuestShootingDemo`, set
to ARM64 and OpenXR with Gradle enabled.

1. Install the matching Godot export templates and configure the Android SDK
   and Java SDK in the editor settings. Install the Android build template
   from the Godot **Project** menu if required by the Gradle build.
2. Connect the Quest over USB and accept its debugging authorization prompt.
3. In **Project > Export**, select the `QuestShootingDemo` preset. Configure
   signing and an export path as needed, then export a debug APK and install
   it, or use Godot's one-click deploy when the device is detected.

See the [Godot Android export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
for the SDK and signing setup.

## Controls

- Press either controller's **trigger** to shoot. Targets respawn after being
  hit.
- Press **A** on the right controller to show or hide the controls panel. It
  remains at its original position when reopened.
- Aim the right controller at the passthrough controls and press **B** to
  interact.
- Use **Simulation enabled** to compare the effect with the unmodified view,
  and **Reset to Defaults** to restore the slider values.

## Passthrough-style simulation

The simulation starts automatically with the player. Its panel controls warp,
swim, edge warp, softness, grain, and edge darkening. Swim responds to head
rotation and continues subtly while stationary; it does not model depth or
head translation. Edge darkening suggests a restricted view but does not
change the headset's actual field of view.

The effect reads the 3D screen texture, so transparent objects and UI may not
be affected. Screen-texture reads and blur samples can be expensive in XR.
Test both eyes and frame rate on the target headset, and stop if the effect
causes discomfort.

See the [simulation guide](docs/passthrough_simulation.md) for details and
build instructions for the [LaTeX equations](docs/passthrough_simulation_equations.tex).
A [compiled equations PDF](docs/passthrough_simulation_equations.pdf) is also
included.

## Project layout

- [`main.tscn`](main.tscn): environment, XR startup, player, and target spawner.
- [`player.tscn`](player.tscn): XR camera, controllers, simulation setup, and
  control panel.
- [`scripts/`](scripts/): simulation setup, motion controller, and panel logic.
- [`shaders/`](shaders/): passthrough-style screen shader.
- [`target_spawner.gd`](target_spawner.gd), [`target.gd`](target.gd), and
  [`bullet.gd`](bullet.gd): shooting and target behavior.

Third-party assets and addons have their own licenses, including
[Godot XR Tools](addons/godot-xr-tools/LICENSE), the
[sci-fi starter kit](Sci-Fi_Starter_Kit/LICENSE.txt), and the license files
within [`addons/godotopenxrvendors/`](addons/godotopenxrvendors/).
