cmake_minimum_required(VERSION 3.15)

if (NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    message(FATAL_ERROR "CMake toolchain file not specified")
endif()

message(STATUS "Toolchain: ${CMAKE_TOOLCHAIN_FILE}")

if (NOT DEFINED MSP_DEVICE)
    message(FATAL_ERROR "MSP430 variant not defined")
endif()

project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(EXECUTABLE ${PROJECT_NAME}.elf)

set(APP_SRCS
    src/main.cpp
)

add_executable(${EXECUTABLE}
    ${APP_SRCS}
)

target_compile_options(${EXECUTABLE} PUBLIC
    -Wall
    -Wextra
    -Wshadow
    -pedantic-errors
    -mmcu=${MSP_DEVICE}
)
target_link_options(${EXECUTABLE} PUBLIC
    -mmcu=${MSP_DEVICE}
    -Wl,-Map=${PROJECT_NAME}.map
)

# Print executable size
add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND ${TOOLCHAIN_PREFIX}size ${EXECUTABLE}
)

# Create hex+bin file
add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND ${TOOLCHAIN_PREFIX}objcopy -O ihex ${EXECUTABLE} ${PROJECT_NAME}.hex
    COMMAND ${TOOLCHAIN_PREFIX}objcopy -O binary ${EXECUTABLE} ${PROJECT_NAME}.bin
)
