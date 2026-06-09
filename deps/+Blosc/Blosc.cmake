if(BUILD_SHARED_LIBS)
    set(_build_shared ON)
    set(_build_static OFF)
else()
    set(_build_shared OFF)
    set(_build_static ON)
endif()

# Platform-specific arguments
if(APPLE)
    # SSE2 support is dropped in Clang of newer Xcode (16.3+) versions
    list(APPEND _blosc_cmake_args -DDEACTIVATE_SSE2=ON)
endif()

add_cmake_project(Blosc
    URL https://github.com/Blosc/c-blosc/archive/8724c06e3da90f10986a253814af18ca081d8de0.zip
    URL_HASH SHA256=53986fd04210b3d94124b7967c857f9766353e576a69595a9393999e0712c035
    CMAKE_ARGS
        -DCMAKE_C_STANDARD:STRING=17
        -DCMAKE_C_EXTENSIONS:BOOL=ON
        -DCMAKE_CXX_STANDARD:STRING=17
        -DCMAKE_CXX_EXTENSIONS:BOOL=ON
        # Override CMAKE_C_FLAGS_RELEASE to append -O2 after any -Og that Yocto
        # injects via CMAKE_C_FLAGS. GCC takes the last -O flag, so -O2 wins and
        # allows always_inline (used by bundled zstd-1.4.1) to be satisfied.
        "-DCMAKE_C_FLAGS_RELEASE:STRING=-DNDEBUG -O2"
        "-DCMAKE_CXX_FLAGS_RELEASE:STRING=-DNDEBUG -O2"
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBUILD_SHARED=${_build_shared}
        -DBUILD_STATIC=${_build_static}
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DPREFER_EXTERNAL_ZLIB=ON
)

set(DEP_Blosc_DEPENDS ZLIB)
