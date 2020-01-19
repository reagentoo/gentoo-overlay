add_library(external_breakpad INTERFACE IMPORTED GLOBAL)
add_library(desktop-app::external_breakpad ALIAS external_breakpad)

find_package(PkgConfig REQUIRED)
pkg_check_modules(BREAKPAD REQUIRED breakpad-client)

target_compile_definitions(
	external_breakpad INTERFACE __STDC_FORMAT_MACROS
)
target_include_directories(
	external_breakpad SYSTEM INTERFACE ${BREAKPAD_INCLUDE_DIRS}
)
target_link_libraries(
	external_breakpad INTERFACE ${BREAKPAD_LIBRARIES}
)
