# MSP430 GCC CMake Template
This is a template for using CMake with the [MSP430 GCC Compiler](https://www.ti.com/tool/MSP430-GCC-OPENSOURCE) that is
maintained by Mitto Systems. 

## Prerequisites
- An installation of the MSP430 GCC Compiler. The default toolchain location is `/opt/ti/msp430-gcc/`. This can be
  changed by editing `TOOLCHAIN_PATH` in the toolchain file (`msp430-elf-gcc.cmake`).
- CMake
- [GNU Make](https://www.gnu.org/software/make/). 
  If [Ninja](https://ninja-build.org/) is installed, it will be used for the build generator. A specific generator can 
  be specified with `CMAKE_GENERATOR=<gen>` in the `Makefile` invocation.

## Usage
The CMake build generator is wrapped in a top-level makefile to exercise each function:

    Available Targets:
      all             Build the target program
      clean           Clean build artifacts
      cmake           Regenerate CMake build system
      distclean       Delete entire build output directory
      flash           Flash the built binary to the device via MSP430-FET or equivalent
      help            List all targets (this message)

The project name and target MSP430 can be specified during the `Makefile` invocation:

    make MSP_DEVICE=msp430f5529 PROJECT_NAME=msp430f5529_launchpad_template

They can also be modified directly in the `Makefile`

## Demo Application
The demo application is targeted at the [MSP-EXP430F5529LP](https://www.ti.com/tool/MSP-EXP430F5529LP) development
board. It pulses the green LED using a PWM signal that varies between 0% and 100% duty cycle.

## License
In short: public domain.

See LICENSE for details.
