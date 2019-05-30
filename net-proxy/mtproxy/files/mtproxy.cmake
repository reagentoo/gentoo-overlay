project(mtproxy)

file(GLOB SOURCE_FILES
	common/*.c
	crypto/*.c
	engine/*.c
	jobs/*.c
	mtproto/*.c
	net/*.c
)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

target_compile_definitions(${PROJECT_NAME} PUBLIC
	AES=1
	_GNU_SOURCE=1
)
target_include_directories(${PROJECT_NAME} PUBLIC
	${CMAKE_CURRENT_SOURCE_DIR}
	common
)
target_link_libraries(${PROJECT_NAME} crypto m pthread rt z)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
