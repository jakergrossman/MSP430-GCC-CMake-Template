PROJECT_NAME ?= msp430f5529_launchpad_template
MSP_DEVICE   ?= msp430f5529

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

CMAKE_PRG ?= $(shell (command -v cmake3 || echo cmake))
CMAKE_BUILD_TYPE ?= RelWithDebInfo
CMAKE_FLAGS := -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
CMAKE_TOOLCHAIN_FILE ?= $(MAKEFILE_DIR)msp430-elf-gcc.cmake

all: $(PROJECT_NAME) ## Build the target program

# extend default set of flags
CMAKE_EXTRA_FLAGS ?=

CMAKE_GENERATOR ?= $(shell (command -v ninja > /dev/null 2>&1 && echo "Ninja") || \
    echo "Unix Makefiles")

ifeq (,$(BUILD_TOOL))
  ifeq (Ninja,$(CMAKE_GENERATOR))
    BUILD_TOOL = ninja
  else
    BUILD_TOOL = $(MAKE)
  endif
endif

# Only need to handle Ninja here.  Make will inherit the VERBOSE variable, and the -j, -l, and -n flags.
ifeq ($(CMAKE_GENERATOR),Ninja)
  ifneq ($(VERBOSE),)
    BUILD_TOOL += -v
  endif
  BUILD_TOOL += $(shell printf '%s' '$(MAKEFLAGS)' | grep -o -- ' *-[jl][0-9]\+ *')
  ifeq (n,$(findstring n,$(firstword -$(MAKEFLAGS))))
    BUILD_TOOL += -n
  endif
endif


$(PROJECT_NAME): build/.ran-$(PROJECT_NAME)-cmake
	+$(BUILD_TOOL) -C build

cmake: ## Regenerate CMake build system
	touch CMakeLists.txt
	@$(MAKE) build/.ran-$(PROJECT_NAME)-cmake -B

build/.ran-$(PROJECT_NAME)-cmake:
	mkdir -p build
	cd build && $(CMAKE_PRG) -G '$(CMAKE_GENERATOR)' \
		-DCMAKE_TOOLCHAIN_FILE=$(CMAKE_TOOLCHAIN_FILE) \
		-DPROJECT_NAME="$(PROJECT_NAME)" \
		-DMSP_DEVICE="$(MSP_DEVICE)" \
		$(CMAKE_FLAGS) $(CMAKE_EXTRA_FLAGS) \
		$(MAKEFILE_DIR)
	touch $@

clean: ## Clean build artifacts
	+test -d build && $(BUILD_TOOL) -C build clean || true

distclean: ## Delete entire build output directory
	rm -rf build
	$(MAKE clean)

flash: $(PROJECT_NAME) ## Flash the built binary to the device via MSP430-FET or equivalent
	@# TODO: more generic
	mspdebug tilib erase "load build/$(PROJECT_NAME).hex"

help: ## List all targets (this message)
	@echo Available Targets:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

.PHONY: clean distclean flash cmake help
