project(nvTriStrip)

cmake_minimum_required(VERSION 2.8.8)

set(INC "include" CACHE PATH "Include path")
set(SRC "src" CACHE PATH "Sources path")
set(LIB "lib" CACHE STRING "Installation directory name")

set(NVTS_SRCS
	${SRC}/NvTriStrip.cpp
	${SRC}/NvTriStripObjects.cpp
)

include_directories(${INC})
add_library(nvtristrip STATIC ${NVTS_SRCS})
set_target_properties(nvtristrip PROPERTIES COMPILE_FLAGS "-fPIC")

install(TARGETS nvtristrip DESTINATION ${LIB})
install(FILES ${INC}/NvTriStrip.h DESTINATION include/NvTriStrip)
