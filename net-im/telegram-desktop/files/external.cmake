find_package(OpenAL REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(Threads REQUIRED)
find_package(X11 REQUIRED)

pkg_check_modules(FFMPEG REQUIRED
	libavcodec
	libavformat
	libavutil
	libswscale
	libswresample
)
pkg_check_modules(LZ4 REQUIRED liblz4)
pkg_check_modules(OPUS REQUIRED opus)
pkg_check_modules(ZLIB REQUIRED minizip zlib)

set(QT_COMPONENTS Core DBus Gui Network Widgets)

find_package(Qt5 REQUIRED COMPONENTS ${QT_COMPONENTS})
get_target_property(QTCORE_INCLUDE_DIRS Qt5::Core INTERFACE_INCLUDE_DIRECTORIES)
list(GET QTCORE_INCLUDE_DIRS 0 QT_INCLUDE_DIR)

foreach(qt_module IN ITEMS ${QT_COMPONENTS})
	list(APPEND QT_PRIVATE_INCLUDE_DIRS
		${QT_INCLUDE_DIR}/Qt${qt_module}/${Qt5_VERSION}
		${QT_INCLUDE_DIR}/Qt${qt_module}/${Qt5_VERSION}/Qt${qt_module}
	)
endforeach()
message(STATUS "Using Qt private include directories: ${QT_PRIVATE_INCLUDE_DIRS}")

set(OPENAL_DEFINITIONS
#	AL_LIBTYPE_STATIC
)

if (NOT TDESKTOP_DISABLE_OPENAL_EFFECTS)
	list(APPEND OPENAL_DEFINITIONS AL_ALEXT_PROTOTYPES)
else()
	# due to missing in CMakeLists (tdesktop-v1.9.3)
	list(APPEND OPENAL_DEFINITIONS TDESKTOP_DISABLE_OPENAL_EFFECTS)
endif()

set(QT_DEFINITIONS
	_REENTRANT
	QT_CORE_LIB
	QT_GUI_LIB
	QT_NETWORK_LIB
	QT_PLUGIN
#	QT_STATICPLUGIN
	QT_WIDGETS_LIB
)

if (build_linux32)
	list(APPEND QT_DEFINITIONS Q_OS_LINUX32)
else()
	list(APPEND QT_DEFINITIONS Q_OS_LINUX64)
endif()

set(OPENAL_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR})
set(QT_INCLUDE_DIRS ${QT_PRIVATE_INCLUDE_DIRS})

set(OPENAL_LIBRARIES ${OPENAL_LIBRARY})
set(OPENSSL_LIBRARIES
	OpenSSL::Crypto
	OpenSSL::SSL
)
set(QT_LIBRARIES
	Qt5::DBus
	Qt5::Network
	Qt5::Widgets
	Threads::Threads dl ${X11_X11_LIB}
)

set(EXTERNAL_LIBS ffmpeg lz4 openal openssl opus qt zlib)

if(NOT DESKTOP_APP_DISABLE_CRASH_REPORTS)
	pkg_check_modules(CRASH_REPORTS REQUIRED breakpad-client)
	list(APPEND EXTERNAL_LIBS crash_reports)
endif()

foreach(ext_lib IN ITEMS ${EXTERNAL_LIBS})
	add_library(external_${ext_lib} INTERFACE IMPORTED GLOBAL)
	add_library(desktop-app::external_${ext_lib} ALIAS external_${ext_lib})
	string(TOUPPER ${ext_lib} ext_lib_u)

	if(DEFINED ${ext_lib_u}_DEFINITIONS)
		target_compile_definitions(
			external_${ext_lib} INTERFACE ${${ext_lib_u}_DEFINITIONS}
		)
	endif()

	if(DEFINED ${ext_lib_u}_INCLUDE_DIRS)
		target_include_directories(
			external_${ext_lib} SYSTEM INTERFACE ${${ext_lib_u}_INCLUDE_DIRS}
		)
	endif()

	if(DEFINED ${ext_lib_u}_LIBRARIES)
		target_link_libraries(
			external_${ext_lib} INTERFACE ${${ext_lib_u}_LIBRARIES}
		)
	endif()
endforeach()
