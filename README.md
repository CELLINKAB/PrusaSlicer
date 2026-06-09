
![PrusaSlicer logo](/resources/icons/PrusaSlicer.png?raw=true)

# PrusaSlicer

You may want to check the [PrusaSlicer project page](https://www.prusa3d.com/prusaslicer/).
Prebuilt Windows, OSX and Linux binaries are available through the [git releases page](https://github.com/prusa3d/PrusaSlicer/releases) or from the [Prusa3D downloads page](https://www.prusa3d.com/drivers/). There are also [3rd party Linux builds available](https://github.com/prusa3d/PrusaSlicer/wiki/PrusaSlicer-on-Linux---binary-distributions).

PrusaSlicer takes 3D models (STL, OBJ, AMF) and converts them into G-code
instructions for FFF printers or PNG layers for mSLA 3D printers. It's
compatible with any modern printer based on the RepRap toolchain, including all
those based on the Marlin, Prusa, Sprinter and Repetier firmware. It also works
with Mach3, LinuxCNC and Machinekit controllers.

PrusaSlicer is based on [Slic3r](https://github.com/Slic3r/Slic3r) by Alessandro Ranellucci and the RepRap community.

See the [project homepage](https://www.prusa3d.com/slic3r-prusa-edition/) and
the [documentation directory](doc/) for more information.

### What language is it written in?

All user facing code is written in C++.
The slicing core is the `libslic3r` library, which can be built and used in a standalone way.
The command line interface is a thin wrapper over `libslic3r`.

### What are PrusaSlicer's main features?

Key features are:

* **multi-platform** (Linux/Mac/Win) and packaged as standalone-app with no dependencies required
* complete **command-line interface** to use it with no GUI
* multi-material **(multiple extruders)** object printing
* multiple G-code flavors supported (RepRap, Makerbot, Mach3, Machinekit etc.)
* ability to plate **multiple objects having distinct print settings**
* **multithread** processing
* **STL auto-repair** (tolerance for broken models)
* wide automated unit testing

Other major features are:

* combine infill every 'n' perimeters layer to speed up printing
* **3D preview** (including multi-material files)
* **multiple layer heights** in a single print
* **spiral vase** mode for bumpless vases
* fine-grained configuration of speed, acceleration, extrusion width
* several infill patterns including honeycomb, spirals, Hilbert curves
* support material, raft, brim, skirt
* **standby temperature** and automatic wiping for multi-extruder printing
* [customizable **G-code macros**](https://github.com/prusa3d/PrusaSlicer/wiki/PrusaSlicer-Macro-Language) and output filename with variable placeholders
* support for **post-processing scripts**
* **cooling logic** controlling fan speed and dynamic print speed

### Development

If you want to compile the source yourself, follow the instructions on one of
these documentation pages:
* [Linux](doc/How%20to%20build%20-%20Linux%20et%20al.md)
* [macOS](doc/How%20to%20build%20-%20Mac%20OS.md)
* [Windows](doc/How%20to%20build%20-%20Windows.md)

#### Building CLI-only (no GUI)

PrusaSlicer can be built as a command-line-only binary without any GUI
dependencies (wxWidgets, OpenGL, GLEW, OpenCSG, CURL, DBus1, OpenVDB).
This produces a smaller binary suitable for headless/server environments.

**Step 1: Build dependencies** (using the `cli-only` preset)

```bash
cd deps
mkdir build
cd build
cmake --preset cli-only
make -j$(nproc)
```

The `cli-only` preset excludes GUI-only packages:
- **wxWidgets** — GUI toolkit (not needed for CLI)
- **OpenCSG** — Constructive solid geometry (GUI-only)
- **OCCT** — STEP file support (GUI-only)
- **Catch2** — Unit testing framework (disabled for CLI builds)
- **GLEW** — OpenGL extension loader (GUI-only)
- **CURL** — Network library (GUI-only features)
- **OpenVDB** — Voxel grid library (GUI-only)
- **OpenEXR** — High dynamic range images (GUI-only)

**Step 2: Build PrusaSlicer**

```bash
cd ..
mkdir build
cd build
cmake .. \
  -DSLIC3R_STATIC=ON \
  -DSLIC3R_PCH=OFF \
  -DSLIC3R_GUI=OFF \
  -DCMAKE_PREFIX_PATH=$(pwd)/../deps/build/destdir/usr/local
make -j$(nproc)
```

The CLI binary will be at `build/src/prusa-slicer`.

**Cross-compilation:**
When cross-compiling, the build system automatically adds the deps install
prefix to `CMAKE_FIND_ROOT_PATH` so that `find_package` works with toolchains
that restrict package search to the sysroot.

**Notes:**
- STEP file import is disabled in CLI builds (requires OCCT). Enable it with
  `-DSLIC3R_ENABLE_FORMAT_STEP=ON` if you provide your own OCCT installation.
- Unit tests are disabled in CLI builds. Enable with `-DSLIC3R_BUILD_TESTS=ON`
  if you provide your own Catch2 installation.

#### Building with Yocto

PrusaSlicer can be cross-compiled for embedded targets using Yocto. The
`yocto` CMake preset is designed for this purpose and inherits from `cli-only`,
with additional packages (`GMP`, `MPFR`, `Boost`, `TBB`, `PNG`, `JPEG`,
`Cereal`, `EXPAT`, `ZLIB`, `nlohmann_json`) delegated to the Yocto sysroot
via `PrusaSlicer_deps_PLATFORM_PACKAGES`.

A minimal Yocto recipe:

```bitbake
SRC_URI = "git://github.com/prusa3d/PrusaSlicer.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

inherit cmake

DEPENDS = " \
    boost gmp libeigen libjpeg-turbo libpng libcereal expat mpfr tbb zlib nlohmann-json \
"

EXTRA_OECMAKE = " \
    -DSLIC3R_GUI=OFF \
    -DSLIC3R_FHS=ON \
    -DSLIC3R_STATIC=ON \
    -DSLIC3R_BUILD_TESTS=OFF \
    -DSLIC3R_ENABLE_FORMAT_STEP=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DPrusaSlicer_BUILD_DEPS=ON \
    -DPrusaSlicer_DEPS_PRESET=yocto \
"
```

The `yocto` preset excludes GUI-only deps and uses the Yocto sysroot for
common libraries, while building embedded-only deps (CGAL, Qhull, NLopt,
LibBGCode, heatshrink, NanoSVG) in-tree.

### Can I help?

Sure! You can do the following to find things that are available to help with:
* Add an [issue](https://github.com/prusa3d/PrusaSlicer/issues) to the github tracker if it isn't already present.
* Look at [issues labeled "volunteer needed"](https://github.com/prusa3d/PrusaSlicer/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3A%22volunteer+needed%22)

### What's PrusaSlicer license?

PrusaSlicer is licensed under the _GNU Affero General Public License, version 3_.
The PrusaSlicer is originally based on Slic3r by Alessandro Ranellucci.

### How can I use PrusaSlicer from the command line?

Please refer to the [Command Line Interface](https://github.com/prusa3d/PrusaSlicer/wiki/Command-Line-Interface) wiki page.
