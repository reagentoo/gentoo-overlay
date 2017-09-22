cmake_minimum_required(VERSION 3.8)

project(TelegramDesktop)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/gyp ${CMAKE_SOURCE_DIR}/cmake)

option(BUILD_TESTS "Build all available test suites" OFF)

find_package(LibLZMA REQUIRED)
find_package(OpenAL REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Threads REQUIRED)
find_package(X11 REQUIRED)
find_package(ZLIB REQUIRED)

find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets Network)
get_target_property(QTCORE_INCLUDE_DIRS Qt5::Core INTERFACE_INCLUDE_DIRECTORIES)
list(GET QTCORE_INCLUDE_DIRS 0 QT_INCLUDE_DIR)

foreach(__qt_module IN ITEMS QtCore QtGui)
	list(APPEND QT_PRIVATE_INCLUDE_DIRS ${QT_INCLUDE_DIR}/${__qt_module}/${Qt5_VERSION})
	list(APPEND QT_PRIVATE_INCLUDE_DIRS ${QT_INCLUDE_DIR}/${__qt_module}/${Qt5_VERSION}/${__qt_module})
endforeach()
message(STATUS "Using Qt private include directories: ${QT_PRIVATE_INCLUDE_DIRS}")

find_package(PkgConfig REQUIRED)

pkg_check_modules(FFMPEG REQUIRED libavcodec libavformat libavutil libswresample libswscale)
pkg_check_modules(LIBDRM REQUIRED libdrm)
pkg_check_modules(LIBVA REQUIRED libva libva-drm libva-x11)
pkg_check_modules(MINIZIP REQUIRED minizip)
pkg_check_modules(OPUS REQUIRED opus)

pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(APPINDICATOR REQUIRED appindicator3-0.1)

set(TGVOIP_LIBS dl opus
	${CMAKE_BINARY_DIR}/ThirdParty/libtgvoip/libtgvoip.a
	${CMAKE_BINARY_DIR}/ThirdParty/libtgvoip/webrtc_dsp/webrtc/libwebrtc.a
)

set(EMOJI_SUGGESTIONS_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/emoji_suggestions)
set(GSL_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/GSL/include)
set(TGVOIP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/libtgvoip)
set(VARIANT_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/variant/include)

set(TELEGRAM_SOURCES_DIR ${CMAKE_SOURCE_DIR}/SourceFiles)
set(TELEGRAM_RESOURCES_DIR ${CMAKE_SOURCE_DIR}/Resources)

include_directories(${TELEGRAM_SOURCES_DIR})

set(GENERATED_DIR ${CMAKE_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${GENERATED_DIR})

add_subdirectory(${CMAKE_SOURCE_DIR}/ThirdParty/libtgvoip)

find_package(Breakpad REQUIRED)

include(TelegramCodegen)
include(TelegramCodegenTools)

set(QRC_FILES
	Resources/qrc/telegram.qrc
	Resources/qrc/telegram_emoji.qrc
	Resources/qrc/telegram_emoji_large.qrc
	# This only disables system plugin search path
	# We do not want this behavior for system build
	# Resources/qrc/telegram_linux.qrc
)

file(GLOB FLAT_SOURCE_FILES SourceFiles/*.cpp)
# We do not want to include Qt plugins statically
list(REMOVE_ITEM FLAT_SOURCE_FILES ${CMAKE_SOURCE_DIR}/SourceFiles/qt_static_plugins.cpp)

file(GLOB_RECURSE SUBDIRS_SOURCE_FILES
	SourceFiles/qt_functions.cpp
	SourceFiles/base/*.cpp
	SourceFiles/boxes/*.cpp
	SourceFiles/calls/*.cpp
	SourceFiles/core/*.cpp
	SourceFiles/chat_helpers/*.cpp
	SourceFiles/data/*.cpp
	SourceFiles/dialogs/*.cpp
	SourceFiles/history/*.cpp
	SourceFiles/inline_bots/*.cpp
	SourceFiles/intro/*.cpp
	SourceFiles/lang/*.cpp
	SourceFiles/media/*.cpp
	SourceFiles/mtproto/*.cpp
	SourceFiles/overview/*.cpp
	SourceFiles/platform/linux/*.cpp
	SourceFiles/profile/*.cpp
	SourceFiles/settings/*.cpp
	SourceFiles/storage/*.cpp
	SourceFiles/ui/*.cpp
	SourceFiles/window/*.cpp
	${EMOJI_SUGGESTIONS_INCLUDE_DIR}/*.cpp
)

file(GLOB FLAGS_TESTS_FILES
	SourceFiles/base/flags_tests.cpp
	SourceFiles/base/tests_main.cpp
)

file(GLOB FLAT_MAP_TESTS_FILES
	SourceFiles/base/flat_map_tests.cpp
	SourceFiles/base/tests_main.cpp
)

file(GLOB FLAT_SET_TESTS_FILES
	SourceFiles/base/flat_set_tests.cpp
	SourceFiles/base/tests_main.cpp
)

list(REMOVE_ITEM SUBDIRS_SOURCE_FILES
	${FLAGS_TESTS_FILES}
	${FLAT_MAP_TESTS_FILES}
	${FLAT_SET_TESTS_FILES}
)

add_executable(Telegram WIN32 ${QRC_FILES} ${FLAT_SOURCE_FILES} ${SUBDIRS_SOURCE_FILES})

target_link_libraries(Telegram
	breakpad
	OpenSSL::Crypto
	OpenSSL::SSL
	Qt5::Network
	Qt5::Widgets
	Threads::Threads
	${APPINDICATOR_LIBRARIES}
	${FFMPEG_LIBRARIES}
	${GTK3_LIBRARIES}
	${OPUS_LIBRARIES}
	${LIBVA_LIBRARIES}
	${LIBDRM_LIBRARIES}
	${LIBLZMA_LIBRARIES}
	${MINIZIP_LIBRARIES}
	${OPENAL_LIBRARY}
	${TGVOIP_LIBS}
	${X11_X11_LIB}
	${ZLIB_LIBRARY_RELEASE}
)

target_include_directories(Telegram PUBLIC
	${APPINDICATOR_INCLUDE_DIRS}
	${EMOJI_SUGGESTIONS_INCLUDE_DIR}
	${GENERATED_DIR}
	${GSL_INCLUDE_DIR}
	${GTK3_INCLUDE_DIRS}
	${FFMPEG_INCLUDE_DIRS}
	${LIBLZMA_INCLUDE_DIRS}
	${LIBVA_INCLUDE_DIRS}
	${LIBDRM_INCLUDE_DIRS}
	${MINIZIP_INCLUDE_DIRS}
	${OPENAL_INCLUDE_DIR}
	${OPUS_INCLUDE_DIRS}
	${QT_PRIVATE_INCLUDE_DIRS}
	${TGVOIP_INCLUDE_DIR}
	${VARIANT_INCLUDE_DIR}
	${ZLIB_INCLUDE_DIR}
)

target_sources(Telegram PRIVATE ${TELEGRAM_GENERATED_SOURCES})
add_dependencies(Telegram telegram_codegen)

include(PrecompiledHeader)
add_precompiled_header(Telegram SourceFiles/stdafx.h)

target_compile_definitions(Telegram PUBLIC
	Q_OS_LINUX64
	TDESKTOP_DISABLE_AUTOUPDATE
	TDESKTOP_DISABLE_UNITY_INTEGRATION
	__STDC_FORMAT_MACROS
)

set_target_properties(Telegram PROPERTIES AUTOMOC_MOC_OPTIONS -bTelegram_pch/stdafx.h)

if(BUILD_TESTS)
	#find_package(catch REQUIRED)
	set(catch_INCLUDE /usr/include/catch)

	file(GLOB LIST_TESTS_PY gyp/tests/list_tests.py)
	file(GLOB TESTS_LIST_TXT gyp/tests/tests_list.txt)

	add_executable(flags_tests ${FLAGS_TESTS_FILES})
	add_executable(flat_map_tests ${FLAT_MAP_TESTS_FILES})
	add_executable(flat_set_tests ${FLAT_SET_TESTS_FILES})

	target_link_libraries(flags_tests Qt5::Core)
	target_link_libraries(flat_map_tests Qt5::Core)
	target_link_libraries(flat_set_tests Qt5::Core)

	target_include_directories(flags_tests PUBLIC
		${catch_INCLUDE}
	)
	target_include_directories(flat_map_tests PUBLIC
		${catch_INCLUDE}
		${VARIANT_INCLUDE_DIR}
	)
	target_include_directories(flat_set_tests PUBLIC
		${catch_INCLUDE}
	)

	enable_testing()
	add_test(tests python ${LIST_TESTS_PY} --input ${TESTS_LIST_TXT})
endif()

install(TARGETS Telegram RUNTIME DESTINATION bin)
install(PROGRAMS ${CMAKE_SOURCE_DIR}/../lib/xdg/telegram-desktop.desktop DESTINATION share/applications)
