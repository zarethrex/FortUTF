# FORTRAN Unit Test Framework

A purely FORTRANic framework for testing FORTRAN code

[![FortUTF Ubuntu GFortran 14](https://github.com/artemis-beta/FortUTF/actions/workflows/futs.yml/badge.svg)](https://github.com/artemis-beta/FortUTF/actions/workflows/futs.yml)
[![FortUTF Windows GFortran 15](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_windows.yml/badge.svg)](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_windows.yml)
[![FortUTF macOS GFortran 15](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_mac.yml/badge.svg)](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_mac.yml)

[![FortUTF Ubuntu Intel 2025](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_intel.yml/badge.svg)](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_intel.yml)
[![FortUTF Ubuntu Flang 20](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_flang.yml/badge.svg)](https://github.com/artemis-beta/FortUTF/actions/workflows/futs_flang.yml)

[![codecov](https://codecov.io/gh/artemis-beta/FortUTF/branch/master/graph/badge.svg?token=tIwLkKYQ98)](https://codecov.io/gh/artemis-beta/FortUTF)

**NOTE**: As of `v0.1.4-alpha` a GFortran compiler supporting FORTRAN-2008 is required for test run command line arguments.

**NOTE**: Currently FortUTF does not support `lfortran`

## Introduction

FortUTF is Unit Test framework written purely in FORTRAN to be compatible with as many projects as possible, the basis for the test suite is template scripts constructed within CMake during configuration. The framework is still in development so documentation is limited, but I promise once it is complete documentation will be a priority. For now I will introduce the basics.


## Writing Tests

The full list of available assertion subroutines can be found in the file [`src/assertions.f90`](https://github.com/zarethrex/FortUTF/blob/main/src/assertions.f90). To write tests create a file containing a subroutine for each scenario, you then can use the macro script contained within FortUTF to construct a main script to build and run the tests.

### Example Project

This repository contains an example project which demonstrates a typical layout of files:

```bash
demo_project/
├── CMakeLists.txt
├── src
│   └── demo_functions.f90
└── tests
    └── test_functions.f90
```

In this example, the functions which we would like to test are contained within the file `src/demo_functions.f90`, and the relevant tests within the file `tests/test_functions.f90`.

When building tests it is important that either the source directory containing the code to be tested, or alternatively the name of the library compiled from these sources using the variables `SRC_FILES` or `SRC_LIBRARY` respectively, the contents of the `CMakeLists.txt` shows this in practice. The variable `FORTUTF_PROJECT_TEST_DIR` must point to the directory containing the test files. In addition to include a directory containing module (`.mod`) files towards building of the library to be tested, set the variable `FORTUTF_PROJECT_MOD_DIR`.

```cmake
cmake_minimum_required(VERSION 3.12)

project(DEMO_PROJ LANGUAGES Fortran)

message(STATUS "[FortUTF Example Project Build]")
message(STATUS "\tProject Source Directory: ${PROJECT_ROOT}")

get_filename_component(FORTUTF_ROOT ../../ ABSOLUTE)

set(FORTUTF_PROJECT_TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tests)
file(GLOB SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.f90)

include(${FORTUTF_ROOT}/cmake/fortutf.cmake)
fortutf_find_tests()
```

Including `cmake/fortutf.cmake` providers the `fortUTF_find_tests` macro which locates and appends the discovered tests. We can place as many scripts in our `FORTUTF_PROJECT_TEST_DIR` location.

Consider the following example:

```fortran
MODULE TEST_DEMO_FUNCTIONS
    USE FORTUTF
    USE DEMO_FUNCTIONS

    CONTAINS
    SUBROUTINE TEST_DEMO_FUNC_1
        USE DEMO_FUNCTIONS, ONLY: DEMO_FUNC_1
        CALL TAG_TEST("TEST_DEMO_FUNC_1")
        CALL ASSERT_EQUAL(DEMO_FUNC_1(10), 95)
    END SUBROUTINE
    SUBROUTINE TEST_DEMO_FUNC_2
        USE DEMO_FUNCTIONS, ONLY: DEMO_FUNC_2
        CALL TAG_TEST("TEST_DEMO_FUNC_2")
        CALL ASSERT_EQUAL(DEMO_FUNC_2(11D0), 32D0)
    END SUBROUTINE
END MODULE TEST_DEMO_FUNCTIONS
```

The `FORTUTF` module is included within every test script to give access to the assertions, and allow us to tag the test using `TAG_TEST` with a name to help identify it in results on failure (not providing a tag will name the test `Test <N>` where `N` is the test number). For convenience and ease the tests are also defined within a module to group them together.

The example is then built by running CMake as normal:

```bash
cmake -Bbuild
cmake --build build
```

in addition to any configuration a script `run_tests.f90` will be created within the build directory and then compiled into a binary.


## Running the Framework Unit Tests

Even a test framework needs tests! FortUTF uses its own style of running to test
all the assertions are behaving properly, to run the tests build them by
running cmake with the option:

```bash
cmake -H. -Bbuild -DBUILD_TESTS=ON
cmake --build build
```

the compiled binary is always named `<PROJECT_NAME>_Tests` and is run to execute the tests:

```bash
./build/FortUTF_Tests
```

Optionally you can specify tests to run by the tagged name:

```bash
./build/FortUTF_Tests TEST_FAIL_EQUAL_CHAR TEST_EQUAL_CHAR
```


## Troubleshooting

If you experience any problems:

- Try deleting the build directory and starting again.
- Try putting the test subroutines into a module
