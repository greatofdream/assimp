find_package(Threads REQUIRED)
include(ExternalProject)

if(MSYS OR MINGW)
	set(DISABLE_PTHREADS ON)
else()
	set(DISABLE_PTHREADS OFF)
endif()

if (MSVC)
	set(RELEASE_LIB_DIR ReleaseLibs)
	set(DEBUG_LIB_DIR DebugLibs)
else()
	set(RELEASE_LIB_DIR "lib")
	set(DEBUG_LIB_DIR "lib")
endif()

set(GTEST_CMAKE_ARGS
	"-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
	"-Dgtest_force_shared_crt=ON"
	"-Dgtest_disable_pthreads:BOOL=${DISABLE_PTHREADS}")
set(GTEST_RELEASE_LIB_DIR "")
set(GTEST_DEBUGLIB_DIR "")
if (MSVC)
	set(GTEST_CMAKE_ARGS ${GTEST_CMAKE_ARGS}
		"-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG:PATH=${DEBUG_LIB_DIR}"
		"-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE:PATH=${RELEASE_LIB_DIR}")
	set(GTEST_LIB_DIR)
endif()

set(GTEST_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/gtest")

ExternalProject_Add(gtest
	# GIT_REPOSITORY https://chromium.googlesource.com/external/googletest
	GIT_REPOSITORY https://github.com/google/googletest.git
	TIMEOUT 10
	PREFIX "${GTEST_PREFIX}"
	CMAKE_ARGS "${GTEST_CMAKE_ARGS}"
	LOG_DOWNLOAD ON
	LOG_CONFIGURE ON
	LOG_BUILD ON
	# Disable install
	INSTALL_COMMAND ""
)

set(LIB_PREFIX "${CMAKE_STATIC_LIBRARY_PREFIX}")
set(LIB_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(GTEST_LOCATION "${GTEST_PREFIX}/src/gtest-build")
set(GTEST_DEBUG_LIBRARIES
	"${GTEST_LOCATION}/${DEBUG_LIB_DIR}/${LIB_PREFIX}gtest${LIB_SUFFIX}"
	"${CMAKE_THREAD_LIBS_INIT}")
SET(GTEST_RELEASE_LIBRARIES
	"${GTEST_LOCATION}/${RELEASE_LIB_DIR}/${LIB_PREFIX}gtest${LIB_SUFFIX}"
	"${CMAKE_THREAD_LIBS_INIT}")

# modified by zaq
MESSAGE(STATUS "libdir:${GTEST_LIB_DIR},${GTEST_RELEASE_LIB_DIR},${GTEST_DEBUGLIB_DIR}")
MESSAGE(STATUS "library:${LIB_PREFIX}gtest${LIB_SUFFIX},${CMAKE_THREAD_LIBS_INIT}")
# modified end

if(MSVC_VERSION EQUAL 1700)
  add_definitions(-D_VARIADIC_MAX=10)
endif()

ExternalProject_Get_Property(gtest source_dir)
#modified by zaq
MESSAGE(STATUS "gtestsrcdir: ${source_dir}")
include_directories(${source_dir}/googletest/include)
# modified end
include_directories(${source_dir}/include)
include_directories(${source_dir}/gtest/include)

ExternalProject_Get_Property(gtest binary_dir)
#modified by zaq
MESSAGE(STATUS "gtestbinarydir: ${binary_dir}")
link_directories(${binary_dir}/lib)
# modified end
link_directories(${binary_dir})
