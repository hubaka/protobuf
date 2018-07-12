cmake_minimum_required(VERSION 2.8)

include(cmakebuild)
set_project_id("_PROJECT_NAME_")

#
# List with modules we depend on
#
add_folder_dependencies(
	"address"
)

add_lib_dependencies(
)

#
# List of public module header files, relative to the module source folder
#
add_public_header_files(
	# "appmain.h"
)

#
# List of source files, relative to the module source folder
#
add_source_files(
	 "appmain.cpp"
)


add_libs_to_exe(
	${DEP_LIBS}
)

#
# Build and install library
#
install_module_exe()