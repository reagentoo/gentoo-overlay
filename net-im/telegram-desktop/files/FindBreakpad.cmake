find_path(BREAKPAD_INCLUDE_DIRS
	NAMES client/linux/handler/exception_handler.h
	PATHS ${BREAKPAD_INCLUDE_DIR}
)

find_library(BREAKPAD_CLIENT_LIBRARY
	NAMES breakpad_client
	PATHS ${BREAKPAD_LIBRARY_DIR}
)

find_package_handle_standard_args(Breakpad DEFAULT_MSG
	BREAKPAD_CLIENT_LIBRARY
	BREAKPAD_INCLUDE_DIRS
)

add_library(breakpad STATIC IMPORTED)
add_dependencies(breakpad breakpad_build)

set_property(TARGET breakpad PROPERTY IMPORTED_LOCATION ${BREAKPAD_CLIENT_LIBRARY})
set_property(TARGET breakpad PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${BREAKPAD_INCLUDE_DIRS})
