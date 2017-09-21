project(tgvoip)

add_subdirectory("${PROJECT_SOURCE_DIR}/webrtc_dsp/webrtc")

find_package(PkgConfig REQUIRED)
pkg_check_modules(OPUS REQUIRED opus)
pkg_check_modules(LIBPULSE REQUIRED libpulse)

file(GLOB TGVOIP_SOURCE_FILES
	"*.cpp"
	"audio/*.cpp"
	"os/linux/*.cpp"
	"os/posix/*.cpp"
)

add_library(${PROJECT_NAME} STATIC ${TGVOIP_SOURCE_FILES} ${WEBRTC_C_SOURCE_FILES} ${WEBRTC_CXX_SOURCE_FILES})
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_DEFINITIONS "TGVOIP_USE_DESKTOP_DSP;")

target_include_directories(${PROJECT_NAME} PUBLIC
	"${OPUS_INCLUDE_DIRS}"
	"${CMAKE_CURRENT_LIST_DIR}/webrtc_dsp"
	"${CMAKE_CURRENT_LIST_DIR}/webrtc_dsp/webrtc"
)

target_link_libraries(${PROJECT_NAME} ${OPUS_LIBRARIES})
