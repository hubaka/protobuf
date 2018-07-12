cmake_minimum_required(VERSION 2.8)

include(cmakebuild)
set_project_id("_PROJECT_NAME_")

add_folder_dependencies()

#
# List of public module header files, relative to the module source folder
#
add_public_header_folder(
	"include"
)

#
# List of public module header files, relative to the module source folder
#
add_public_header_files(
)

#
# List of source files, relative to the module source folder
#
add_source_files(
	"protodummy.cpp"
	"addressbook.proto"
)

#
# Build and install library
#
install_module_lib()
