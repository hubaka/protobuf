cmake_minimum_required(VERSION 2.8)

# include CMake CSharpUtilities if you are planning on using WPF or other designer properties.
# include(CSharpUtilities)

set (DEBUG_PRINTS FALSE)
# force Unicode over Multi-byte
# building the project as unicode instead of multi-byte project
if(MSVC)
    #add_definitions(-DUNICODE -D_UNICODE)
	if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		include(libpath)
		set(RUNTIMELIB "/MTd")
		set(RUNTIMESHAREDLIB "/MDd")
	else()
		include(libpath)
		set(RUNTIMELIB "/MT")
		set(RUNTIMESHAREDLIB "/MD")
	endif()
endif()

if(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
	set(BFW_ROOT_DIR TRUE)
	set(BFW_TARGET_OBJECTS CACHE INTERNAL "")
else()
	set(BFW_ROOT_DIR FALSE)
	set(IS_LIB_FOLDER FALSE CACHE STRING "")
endif()

#-----------------------------------------------------------------------------------------
# MACRO	set_project_id
#		Folder name is set as the project id, which will be added to the build
#
# INPUT
#		${ARGN}	: Folder name
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(set_project_id id)
	# folder name is set as project id
	get_filename_component(PROJECT_ID ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	string(REPLACE " " "_" PROJECT_ID ${PROJECT_ID})
	project(${PROJECT_ID})
	#enable_language(CSharp)
	if (DEBUG_PRINTS)
		message(STATUS "aka: set_project_id ${PROJECT_ID}")
	endif()
	
	# Turn on the ability to create folders to organize projects (.vcproj)
	# It creates "CMakePredefinedTargets" folder by default and adds CMake
	# defined projects like INSTALL.vcproj and ZERO_CHECK.vcproj
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)
	
	getLibraryName(LIBRARYNAME ${PROJECT_ID})
	
	# Creates the intall directory to store the binaries, libraries & executables
	if(BFW_ROOT_DIR)
		file(MAKE_DIRECTORY ${PROJECT_INSTALL_DIRECTORY})
	elseif (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/source)
		file(MAKE_DIRECTORY ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID})
	endif()
	_config_module()
endmacro()

#-----------------------------------------------------------------------------------------
# FUNC	getLibraryName
#		Based on the build options ("BUILD_TYPE"), library name is created and returned
#
# INPUT
#		libraryName	: "Name" in which the library name will be created.
#		folderName	: folder name
#
# OUTPUT
#		libraryName : library name
#-----------------------------------------------------------------------------------------
function(getLibraryName libraryName folderName)
	if (DEBUG_PRINTS)
		message(STATUS "aka: getLibraryName ${PROJECT_ID}")
	endif()
	# Debug versus release naming
	if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		set(BUILD_TYPE "d")
	else()
		set(BUILD_TYPE "r")
	endif()
	set(${libraryName} ${folderName}_${BUILD_TYPE} PARENT_SCOPE)
endfunction()

#-----------------------------------------------------------------------------------------
# MACRO	_config_module
#		This macro does the basic module configuration
#
# INPUT
#		none	: 
#
# OUTPUT
#		none	: 
#
#		NOTE: 
#-----------------------------------------------------------------------------------------
macro(_config_module)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _config_module ${PROJECT_ID}")
	endif()
	if(NOT BFW_ROOT_DIR)
		#
		# Initialize some module variables that will be used to collect different kind of files
		#
		set(${PROJECT_ID}_PUBLIC_HEADER)		# Module public header files list
		set(${PROJECT_ID}_SRC)					# Module source code files list
		set(${PROJECT_ID}_LIBS)					# Module libs list
		set(${PROJECT_ID}_DEPENDS)				# Module dependency list
		set(${PROJECT_ID}_PUBLIC_HDR_RETAIN_FOLDERNAME FALSE)				# Macro to retain the folder structure (for opencv)
		set(${PROJECT_ID}_PUBLIC_HDR_RELATIVEPATH)				# Macro to retain the folder structure (for opencv)
		set(${PROJECT_ID}_PROJECT_SETTING)				# Macro to project settings C#
		set(${PROJECT_ID}_PROTO_FILES)				# Macro to store .proto files

		# Include needed directories
		include_directories(
			"${CMAKE_CURRENT_SOURCE_DIR}/source"							# Module's common source and header files
		)
	endif()
  
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_source_layers
#		Source layer is added to the source list, which will be used to set these
#		directories as the sub directory for building
#
# INPUT
#		${ARGN}	: List of the folder names, which will be added as source folders
#					- First argument will be depicting the type of folder 
#							("s" as source folder)
#					- Second argument will be mentioning the name of the folder
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(add_source_layers)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_source_layers ${PROJECT_ID}")
	endif()
	if(${ARGC})
		set(src_type FALSE)
		# _src_layer_list - list to store the source folder names
		set(_src_layer_list)
		set(_bin_layer_list)
		set(_lib_layer_list)
		foreach(idx ${ARGN})
			if (NOT src_type)
				set(src_type ${idx})
			else()
				if (${src_type} STREQUAL "s")
					list(APPEND _src_layer_list ${idx})
				elseif (${src_type} STREQUAL "l")
					list(APPEND _lib_layer_list ${idx})
				else()
					message(FATAL_ERROR "invalid argument")
				endif()
				set(src_type FALSE)
			endif()
		endforeach()
	endif()
	if (_bin_layer_list)
		_add_binary_layers(${_bin_layer_list})
	endif()
	if (_src_layer_list)
		_add_source_layers(${_src_layer_list})
	endif()
	if (_lib_layer_list)
		_add_library_layers(${_lib_layer_list})
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_library_layers
#		Adds the static library folders from list received via argument to the build as subdirectory
#
# INPUT
#		${ARGN}	: List of the folder names, which will be added as source folders
#					- First argument will be depicting the type of folder 
#							("s" as source folder)
#					- Second argument will be mentioning the name of the folder
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(_add_library_layers)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_library_layers ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(idx ${ARGN})
			set(folder_source_path ${CMAKE_SOURCE_DIR}/../${idx})
			set(folder_binary_path ${CMAKE_BINARY_DIR}/${idx})
			if (IS_DIRECTORY ${folder_source_path})
				add_subdirectory(${folder_source_path} ${folder_binary_path})
			else()
				message(FATAL_ERROR "Could not find the directory of folder: ${idx}")
			endif()
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_source_layers
#		Adds the source folders from list received via argument to the build as subdirectory
#
# INPUT
#		${ARGN}	: List of the folder names, which will be added as source folders
#					- First argument will be depicting the type of folder 
#							("s" as source folder)
#					- Second argument will be mentioning the name of the folder
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(_add_source_layers)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_source_layers ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(idx ${ARGN})
			set(folder_source_path ${CMAKE_SOURCE_DIR}/../${idx})
			set(folder_binary_path ${CMAKE_BINARY_DIR}/${idx})
			if (IS_DIRECTORY ${folder_source_path})
				add_subdirectory(${folder_source_path} ${folder_binary_path})
			else()
				message(FATAL_ERROR "Could not find the directory of folder: ${idx}")
			endif()
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_subfolder_dependency
#		This macro checks whether "subfolder.cmake" is available.
#		If the above mentioined cmake script is not available, then sub folders will not be
#		added as sub-directories.
#		If the cmake script is available, then folders mentioned inside this script shall be
#		added as sub-directories.
#
# INPUT
#		none
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(add_subfolder_dependency)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_subfolder_dependency ${PROJECT_ID}")
	endif()
	set(subfolder ${CMAKE_CURRENT_SOURCE_DIR}/subfolder.cmake)
	if (EXISTS ${subfolder})
		include(${subfolder})
		set(subfolder_list ${${PROJECT_ID}_SUB_FOLDER_LIST})
	endif()
	foreach(idx ${subfolder_list})
		set(subfolder_path ${CMAKE_CURRENT_SOURCE_DIR}/${idx})
		if (EXISTS ${subfolder_path})
			add_subdirectory(${idx})
		else()
			message(FATAL_ERROR "error: unable to find subfolder: ${subfolder_path}")
		endif()
	endforeach()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_subfolder
#		Adds the sub folder within current directory to the build
#
# INPUT
#		${ARGC} List of sub folder names
#
# OUTPUT
#		${PROJECT_ID}_SUB_FOLDER_LIST - updates this list with sub-folder names
#
#-----------------------------------------------------------------------------------------
macro(add_subfolder)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_subfolder ${PROJECT_ID}")
	endif()
	if (${ARGC})
		set(_binary_layer_list ${BINARY_LAYER_LIST})
		foreach(idx ${ARGN})
			list(APPEND ${PROJECT_ID}_SUB_FOLDER_LIST ${idx})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_folder_dependencies
#		Folder mentioned will be included as directory dependencies while 
#		building the corresponding library/executable
#
# INPUT
#		${ARGC}	-	List of the folder names, which should be included with the 
#					library/executable build
#
# OUTPUT
#		${PROJECT_ID}_DEPENDS - This shall be updated with the folder names.
#
#-----------------------------------------------------------------------------------------
macro(add_folder_dependencies)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_folder_dependencies ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(foldername ${ARGN})
			set(COMPONENT_PATH "NOT_FOUND")
			if (${COMPONENT_PATH} STREQUAL "NOT_FOUND")
				set(_layer_dir ${PROJECT_INSTALL_DIRECTORY})
				# Try to find an external component in the install directory
				if (IS_DIRECTORY ${_layer_dir})
					get_filename_component(COMPONENT_PATH ${_layer_dir}/${foldername} ABSOLUTE)
				endif()
			endif()
			if (NOT ${COMPONENT_PATH} STREQUAL "NOT_FOUND")
				# We've found the dependency, so include its public headers folder
				include_directories(${COMPONENT_PATH})
				list(APPEND ${PROJECT_ID}_DEPENDS ${foldername})
			endif()
		endforeach()
		
		if(${PROJECT_ID}_DEPENDS)
			list(REMOVE_DUPLICATES ${PROJECT_ID}_DEPENDS)
		endif()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_lib_dependencies
#		Folder mentioned will be included as directory dependencies while 
#		building the corresponding library/executable
#
# INPUT
#		${ARGC}	-	List of the folder names, which should be included with the 
#					library/executable build
#
# OUTPUT
#		${PROJECT_ID}_DEPENDS - This shall be updated with the folder names.
#
#-----------------------------------------------------------------------------------------
macro(add_lib_dependencies)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_lib_dependencies ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(foldername ${ARGN})
			set(COMPONENT_PATH "NOT_FOUND")
			if (${COMPONENT_PATH} STREQUAL "NOT_FOUND")
				set(_layer_dir ${PROJECT_INSTALL_DIRECTORY})
				# Try to find an external component in the install directory
				if (IS_DIRECTORY ${_layer_dir})
					get_filename_component(COMPONENT_PATH ${_layer_dir}/${foldername} ABSOLUTE)
				endif()
			endif()
			if (NOT ${COMPONENT_PATH} STREQUAL "NOT_FOUND")
				# We've found the dependency, so include its public headers folder
				include_directories(${COMPONENT_PATH})
			endif()
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_public_header_files
#		creates list of header files, which will be accessed across project
#
# INPUT
#		{ARGC}	-	List of the header file names
#
# OUTPUT
#		${PROJECT_ID}_PUBLIC_HEADER - updates this list with the header file names
#
#-----------------------------------------------------------------------------------------
macro(add_public_header_files)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_public_header_files ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(hdr_filename ${ARGN})
			_add_header_file(${CMAKE_CURRENT_SOURCE_DIR}/source/${hdr_filename})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_header_file
#		creates list of header files, which will be accessed across project
#
# INPUT
#		{ARGC}	-	List of the header file names
#
# OUTPUT
#		${PROJECT_ID}_PUBLIC_HEADER - updates this list with the header file names
#		
#-----------------------------------------------------------------------------------------
macro(_add_header_file hdr_file)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_header_file ${PROJECT_ID}")
	endif()
	get_filename_component(hdr_file_absolute_path ${hdr_file} ABSOLUTE)
	if (${hdr_file_absolute_path} MATCHES \\.h$|\\.hpp$)
		if(NOT EXISTS ${hdr_file_absolute_path})
			message(FATAL_ERROR "${hdr_file_absolute_path} does not exist")
		endif()
		list(APPEND ${PROJECT_ID}_PUBLIC_HEADER ${hdr_file_absolute_path})
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_public_header_folder
#		createst list of public header files present inside the sub-folders,
#		which will be accessed across projects
#
# INPUT
#		{ARGC}	-	top folder name, which contains several sub-folders holding public
#					 header files
#
# OUTPUT
#		${PROJECT_ID}_PUBLIC_HEADER - updates this list with the header file names
#
#-----------------------------------------------------------------------------------------
macro(add_public_header_folder)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_public_header_folder ${PROJECT_ID}")
	endif()
	if (${ARGC})
		file(GLOB_RECURSE HHDRFILENAME RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/source/ *.h*)
		set(${PROJECT_ID}_PUBLIC_HDR_RETAIN_FOLDERNAME TRUE)
		set(${PROJECT_ID}_PUBLIC_HDR_RELATIVEPATH ${CMAKE_CURRENT_SOURCE_DIR}/source/${ARGN})
		foreach(hdr_foldername ${HHDRFILENAME})
			#message(STATUS "aka folName: ${hdr_foldername}")
			_add_header_file(${CMAKE_CURRENT_SOURCE_DIR}/source/${hdr_foldername})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_source_files
#		creates list of source files, which will be added to build
#
# INPUT
#		{ARGC}	-	List of the source file names
#
# OUTPUT
#		${PROJECT_ID}_SRC - updates this list with the source file names
#
#-----------------------------------------------------------------------------------------
macro(add_source_files)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_source_files ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(src ${ARGN})
			_add_source_file(${CMAKE_CURRENT_SOURCE_DIR}/source/${src})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_source_file
#		creates list of source files, which will be added to build
#
# INPUT
#		{ARGC}	-	List of the source file names
#
# OUTPUT
#		${PROJECT_ID}_SRC - updates this list with the source file names
#
#-----------------------------------------------------------------------------------------
macro(_add_source_file src_file)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_source_file ${PROJECT_ID}")
	endif()
	get_filename_component(src_file_absolute_path ${src_file} ABSOLUTE)
	if (${src_file_absolute_path} MATCHES \\.proto$)
		list(APPEND ${PROJECT_ID}_PROTO_FILES ${src_file_absolute_path})
	elseif (${src_file_absolute_path} MATCHES \\.c$|\\.cpp$|\\.rc$|\\.cs$|\\.resx$)
		list(APPEND ${PROJECT_ID}_SRC ${src_file_absolute_path})
	else()
		message(FATAL_ERROR "${src_file_absolute_path} not found")
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_resource_files
#		creates list of resource files, which will be added to build
#
# INPUT
#		{ARGC}	-	List of the resource file names
#
# OUTPUT
#		${PROJECT_ID}_SRC - updates this list with the resource file names
#
#-----------------------------------------------------------------------------------------
macro(add_resource_files)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_resource_files ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(src ${ARGN})
			_add_resource_file(${CMAKE_CURRENT_SOURCE_DIR}/source/${src})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_designer_cs_properties
#		sets the designer CS properties
#
# INPUT
#		{ARGC}	-	List of the settings file names
#
# OUTPUT
#		${PROJECT_ID}_CS_SETTINGS - updates this list with the resource file names
#
#-----------------------------------------------------------------------------------------
macro(add_designer_cs_properties)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_designer_cs_properties ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(src ${ARGN})
			_add_designer_cs_properties(${CMAKE_CURRENT_SOURCE_DIR}/source/${src})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_resource_file
#		creates list of resource files, which will be added to build
#
# INPUT
#		{ARGC}	-	List of the resource file names
#
# OUTPUT
#		${PROJECT_ID}_SRC - updates this list with the resource file names
#
#-----------------------------------------------------------------------------------------
macro(_add_resource_file resrc_file)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_resource_file ${PROJECT_ID}")
	endif()
	get_filename_component(resrc_file_absolute_path ${resrc_file} ABSOLUTE)
	if (${resrc_file_absolute_path} MATCHES \\.rc$|\\.resx$|\\.config$|\\.settings$)
		list(APPEND ${PROJECT_ID}_SRC ${resrc_file_absolute_path})
	else()
		message(FATAL_ERROR "${resrc_file_absolute_path} not found")
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_resource_file
#		creates list of resource files, which will be added to build
#
# INPUT
#		{ARGC}	-	List of the resource file names
#
# OUTPUT
#		${PROJECT_ID}_SRC - updates this list with the resource file names
#
#-----------------------------------------------------------------------------------------
macro(_add_designer_cs_properties setting_file)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_designer_cs_properties ${PROJECT_ID}")
	endif()
	get_filename_component(setting_file_absolute_path ${setting_file} ABSOLUTE)
	if (${setting_file_absolute_path} MATCHES \\.rc$|\\.resx$|\\.config$|\\.settings$|\\.cs$)
		list(APPEND ${PROJECT_ID}_PROJECT_SETTING ${setting_file_absolute_path})
	else()
		message(FATAL_ERROR "${setting_file_absolute_path} not found")
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	install_module_lib
#		Library of the module is built in this function
#
# INPUT
#		none
#
# OUTPUT
#		module library
#
#-----------------------------------------------------------------------------------------
macro(install_module_lib)
	if (DEBUG_PRINTS)
		message(STATUS "aka: install_module_lib ${PROJECT_ID}")
	endif()
	if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/source)
		message(FATAL_ERROR "There is no source folder")
	endif()
	
	if(${PROJECT_ID}_PUBLIC_HEADER)
		list(REMOVE_DUPLICATES ${PROJECT_ID}_PUBLIC_HEADER)
	endif()
	
	_add_module_lib()
	
	get_filename_component(_LIB_INSTALL_DIR ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID} ABSOLUTE)
	
	#
	# Purge any headers that are no longer part of the public ones.
	#
	file(GLOB _fullfoundhdrs "${_LIB_INSTALL_DIR}/*.h*")
	set(_install_hdrs)
	foreach(_header ${_fullfoundhdrs})
		get_filename_component(_name ${_header} NAME)
		list(APPEND _install_hdrs ${_name})
	endforeach()
	
	if(_install_hdrs)
		set(_hdrs)
		foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
			get_filename_component(_name ${_header} NAME)
			list(APPEND _hdrs ${_name})
		endforeach()
		
		foreach(_header ${_hdrs})
			list(REMOVE_ITEM _install_hdrs ${_hdrs})
		endforeach()
		
		foreach(_header ${_install_hdrs})
			message("Purging dead header file: ${_LIB_INSTALL_DIR}/${_header}")
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${_LIB_INSTALL_DIR}/${_header})
		endforeach()
	endif()
	
	#
	# Copy public header files to install dir
	#
	set(_clean_headers)
	foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
		if (NOT ${PROJECT_ID}_PUBLIC_HDR_RETAIN_FOLDERNAME)
			configure_file(${_header} ${_LIB_INSTALL_DIR} COPYONLY)
		else()
			string(REPLACE "${${PROJECT_ID}_PUBLIC_HDR_RELATIVEPATH}" "" HDRFOLDERPATH ${_header})
			configure_file(${_header} ${_LIB_INSTALL_DIR}/${HDRFOLDERPATH} COPYONLY)
		endif()
	endforeach()
	set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${_clean_headers}")
	set_target_properties(${LIBRARYNAME} PROPERTIES COMPILE_FLAGS ${RUNTIMELIB})
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	install_shared_module_lib
#		shared Library (dll) of the module is built in this function
#
# INPUT
#		none
#
# OUTPUT
#		module library
#
#-----------------------------------------------------------------------------------------
macro(install_shared_module_lib)
	if (DEBUG_PRINTS)
		message(STATUS "aka: install_shared_module_lib ${PROJECT_ID}")
	endif()
	if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/source)
		message(FATAL_ERROR "There is no source folder")
	endif()
	
	if(${PROJECT_ID}_PUBLIC_HEADER)
		list(REMOVE_DUPLICATES ${PROJECT_ID}_PUBLIC_HEADER)
	endif()
	
	_add_shared_module_lib()
	
	get_filename_component(_LIB_INSTALL_DIR ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID} ABSOLUTE)
	
	#
	# Purge any headers that are no longer part of the public ones.
	#
	file(GLOB _fullfoundhdrs "${_LIB_INSTALL_DIR}/*.h*")
	set(_install_hdrs)
	foreach(_header ${_fullfoundhdrs})
		get_filename_component(_name ${_header} NAME)
		list(APPEND _install_hdrs ${_name})
	endforeach()
	
	if(_install_hdrs)
		set(_hdrs)
		foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
			get_filename_component(_name ${_header} NAME)
			list(APPEND _hdrs ${_name})
		endforeach()
		
		foreach(_header ${_hdrs})
			list(REMOVE_ITEM _install_hdrs ${_hdrs})
		endforeach()
		
		foreach(_header ${_install_hdrs})
			message("Purging dead header file: ${_LIB_INSTALL_DIR}/${_header}")
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${_LIB_INSTALL_DIR}/${_header})
		endforeach()
	endif()
	
	#
	# Copy public header files to install dir
	#
	set(_clean_headers)
	foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
		if (NOT ${PROJECT_ID}_PUBLIC_HDR_RETAIN_FOLDERNAME)
			configure_file(${_header} ${_LIB_INSTALL_DIR} COPYONLY)
		else()
			#message(STATUS "aka: hit ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID}")
			#message(STATUS "aka: hit ${${PROJECT_ID}_PUBLIC_HDR_RELATIVEPATH}")
			string(REPLACE "${${PROJECT_ID}_PUBLIC_HDR_RELATIVEPATH}" "" HDRFOLDERPATH ${_header})
			#message(STATUS "aka: hit ${OUTPUTSTRING} ${_LIB_INSTALL_DIR}")
			configure_file(${_header} ${_LIB_INSTALL_DIR}/${HDRFOLDERPATH} COPYONLY)
		endif()
	endforeach()
	set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${_clean_headers}")
	#set_target_properties(${LIBRARYNAME} PROPERTIES COMPILE_FLAGS ${RUNTIMESHAREDLIB})
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_lib_files
#		Library of the module is built in this function
#
# INPUT
#		none
#
# OUTPUT
#		module library
#
#-----------------------------------------------------------------------------------------
macro(add_lib_header_files)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_lib_header_files  ${PROJECT_ID}")
	endif()
	if(${PROJECT_ID}_PUBLIC_HEADER)
		list(REMOVE_DUPLICATES ${PROJECT_ID}_PUBLIC_HEADER)
	endif()
	
	
	get_filename_component(_LIB_INSTALL_DIR ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID} ABSOLUTE)
	
	#
	# Purge any headers that are no longer part of the public ones.
	#
	file(GLOB _fullfoundhdrs "${_LIB_INSTALL_DIR}/*.h*")
	set(_install_hdrs)
	foreach(_header ${_fullfoundhdrs})
		get_filename_component(_name ${_header} NAME)
		list(APPEND _install_hdrs ${_name})
	endforeach()
	if(_install_hdrs)
		set(_hdrs)
		foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
			get_filename_component(_name ${_header} NAME)
			list(APPEND _hdrs ${_name})
		endforeach()
		
		foreach(_header ${_hdrs})
			list(REMOVE_ITEM _install_hdrs ${_hdrs})
		endforeach()
		
		foreach(_header ${_install_hdrs})
			message("Purging dead header file: ${_LIB_INSTALL_DIR}/${_header}")
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${_LIB_INSTALL_DIR}/${_header})
		endforeach()
	endif()
	
	#
	# Copy public header files to install dir
	#
	set(_clean_headers)
	foreach(_header ${${PROJECT_ID}_PUBLIC_HEADER})
		configure_file(${_header} ${_LIB_INSTALL_DIR} COPYONLY)
	endforeach()
	set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${_clean_headers}")

endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_module_lib
#		
#
# INPUT
#		
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(_add_module_lib)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_module_lib ${PROJECT_ID}")
		message(STATUS "aka: lib name ${${PROJECT_ID}_LIBS}")
	endif()
		add_library(${LIBRARYNAME} STATIC ${${PROJECT_ID}_SRC} ${${PROJECT_ID}_PUBLIC_HEADER})
		if (${PROJECT_ID}_PROTO_FILES)
			_add_proto_files(${${PROJECT_ID}_PROTO_FILES})
		endif()
		target_link_libraries(${LIBRARYNAME} ${${PROJECT_ID}_LIBS})
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_proto_files
#		
#
# INPUT
#		
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro (_add_proto_files)
	if (TRUE)
		message(STATUS "aka: _add_proto_files ${PROJECT_ID}")
	endif()
	
	get_filename_component(proto_install_directory ${PROJECT_INSTALL_DIRECTORY}/${PROJECT_ID} ABSOLUTE)
	
	set(PROJECT_PROTO_EXECUTABLE ${CMAKE_BINARY_DIR}/../buildsystem/protobuf/protoc.exe)
	foreach (proto_src_file ${ARGN})
		set(PROJECT_PROTO_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/proto)
		if (NOT IS_DIRECTORY ${PROJECT_PROTO_OUTPUT_DIR})
			file(MAKE_DIRECTORY ${PROJECT_PROTO_OUTPUT_DIR})
		endif()

		# Get the file name from the full path
		get_filename_component(proto_src_file_name ${proto_src_file} NAME_WE)
		set(PROJECT_PROTO_OUTPUT_FILES ${PROJECT_PROTO_OUTPUT_DIR}/${proto_src_file_name}.pb.cc 
									${PROJECT_PROTO_OUTPUT_DIR}/${proto_src_file_name}.pb.h)
		# protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/addressbook.proto
		message(STATUS "aka: build path ${proto_install_directory}")
		add_custom_command(
			OUTPUT ${PROJECT_PROTO_OUTPUT_FILES}
			COMMAND ${PROJECT_PROTO_EXECUTABLE} -I=${CMAKE_CURRENT_SOURCE_DIR}/source --cpp_out=${PROJECT_PROTO_OUTPUT_DIR} ${proto_src_file}
			COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_PROTO_OUTPUT_DIR}/${proto_src_file_name}.pb.h ${proto_install_directory}/${proto_src_file_name}.pb.h
		)
		
		add_custom_target("${PROJECT_ID}_DUMMY_TARGET" DEPENDS ${PROJECT_PROTO_OUTPUT_FILES})	
		add_dependencies(${LIBRARYNAME} "${PROJECT_ID}_DUMMY_TARGET")
		
		# Add these generated proto header files to the public header list of this project
		_add_public_proto_headers(
			"${proto_src_file_name}.pb.h"
		)
		# Add the generated cpp source proto files to the project source list
		# list(APPEND
			# ${PROJECT_ID}_SRC
			# ${PROJECT_PROTO_OUTPUT_DIR}/${proto_src_file_name}.pb.cc
		# )
	endforeach(proto_src_file)
	
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_public_proto_headers
#		This macro adds the module public Goggle Protocol Buffer headers to the headers list
#
# INPUT
#		${ARGN}	: list with the header files to add
#
# OUTPUT
#		none	: 
#
#		NOTE: 
#-----------------------------------------------------------------------------------------
macro(_add_public_proto_headers)
	if (TRUE)
		message(STATUS "aka: _add_public_proto_headers ${PROJECT_ID}")
	endif()
	if (${ARGC})
		foreach(hdr ${ARGN})
			_add_header_file(${CMAKE_CURRENT_BINARY_DIR}/proto/${hdr})
		endforeach()
	endif()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_module_lib
#		
#
# INPUT
#		
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(_add_shared_module_lib)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_shared_module_lib ${PROJECT_ID}")
		message(STATUS "aka: lib name ${LIBRARYNAME}")
	endif()
	
	set(_dependent_libs)
	foreach(_lib ${${PROJECT_ID}_DEPENDS})
		getLibraryName(_libname ${_lib})
		list(APPEND _dependent_libs "${_libname}")
	endforeach()
	
	if (DEBUG_PRINTS)
		message(STATUS "----> aka: dependent libs ${${PROJECT_ID}_PUBLIC_HEADER}")
	endif()

	
	
	add_library(${LIBRARYNAME} SHARED ${${PROJECT_ID}_SRC} ${${PROJECT_ID}_PUBLIC_HEADER})
	target_link_libraries(${LIBRARYNAME} ${_dependent_libs})
	#SET_TARGET_PROPERTIES(${LIBRARYNAME} PROPERTIES COMPILE_FLAGS "/clr") 
	target_compile_options(${LIBRARYNAME} PRIVATE /clr)
	set_target_properties(${LIBRARYNAME} PROPERTIES COMPILE_FLAGS ${RUNTIMESHAREDLIB})
	if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		set_target_properties(${LIBRARYNAME} PROPERTIES LINK_FLAGS_DEBUG   "/ASSEMBLYDEBUG")
	endif()
	string(REPLACE "/EHsc" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	add_libs_to_exe
#		This macro adds external libraries to the project
#
# INPUT
#		${ARGN}	: list with the libraries to the added, with full path
#
# OUTPUT
#		none	: 
#
#		NOTE:
#-----------------------------------------------------------------------------------------
macro(add_libs_to_exe)
	if (DEBUG_PRINTS)
		message(STATUS "aka: add_libs_to_exe ${PROJECT_ID}")
	endif()
	foreach(lib ${ARGN})
		list(APPEND ${PROJECT_ID}_LIBS ${lib})
	endforeach()
	list(REMOVE_DUPLICATES ${PROJECT_ID}_LIBS)
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	install_module_exe
#		This macro adds the current module as an executable to the build system
#
# INPUT
#		none	: 
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(install_module_exe)
	if (DEBUG_PRINTS)
		message(STATUS "aka: install_module_exe ${PROJECT_ID}")
	endif()
	#
	# Set the executable output path
	#
	get_filename_component(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_INSTALL_DIRECTORY}/../images/ ABSOLUTE)
	#
	# Install folder
	#
	file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
	_add_module_exe()
endmacro()

#-----------------------------------------------------------------------------------------
# MACRO	_add_module_exe
#		This macro adds the current module as an executable to the build system
#
# INPUT
#		none	: 
#
# OUTPUT
#		none	: 
#
#-----------------------------------------------------------------------------------------
macro(_add_module_exe)
	if (DEBUG_PRINTS)
		message(STATUS "aka: _add_module_exe ${PROJECT_ID}")
	endif()
	
	set(_dependent_libs)
	foreach(_lib ${${PROJECT_ID}_DEPENDS})
		getLibraryName(_libname ${_lib})
		list(APPEND _dependent_libs "${_libname}")
	endforeach()

	if (DEBUG_PRINTS)
		message(STATUS "aka: obj libs ${_dependent_libs}")
	endif()
	add_executable(${LIBRARYNAME} ${${PROJECT_ID}_SRC} ${${PROJECT_ID}_PUBLIC_HEADER})
	target_link_libraries(${LIBRARYNAME} ${${PROJECT_ID}_LIBS})
	target_link_libraries(${LIBRARYNAME} ${_dependent_libs})
	#csharp_set_windows_forms_properties(${${PROJECT_ID}_PROJECT_SETTING})
	
	if(MSVC)
		# 	/SUBSYSTEM:WINDOWS --> 	this flag creates the project as "windows project" 
		#	/SUBSYSTEM:CONSOLE --> 	this flag creates the project as "windows console project"
		set_target_properties(${LIBRARYNAME} PROPERTIES LINK_FLAGS_DEBUG   "/NODEFAULTLIB:msvcrt /NODEFAULTLIB:libcd /SUBSYSTEM:CONSOLE")
		set_target_properties(${LIBRARYNAME} PROPERTIES LINK_FLAGS_RELEASE "/NODEFAULTLIB:msvcrtd /NODEFAULTLIB:libcd /SUBSYSTEM:CONSOLE")
		# set_property(TARGET ${LIBRARYNAME} PROPERTY VS_DOTNET_TARGET_FRAMEWORK_VERSION "v4.6.1")
		# set_property(TARGET ${LIBRARYNAME} PROPERTY WIN32_EXECUTABLE TRUE)
		# set_property(TARGET ${LIBRARYNAME} PROPERTY VS_DOTNET_REFERENCES
				# "Microsoft.CSharp"
				# "PresentationCore"
				# "PresentationFramework"
				# "System"
				# "System.Windows.Forms"
				# "System.Core"
				# "System.Drawing"
				# "System.Data"
				# "System.Data.DataSetExtensions"
				# "System.Net.Http"
				# "System.Xaml"
				# "System.Xml"
				# "System.Xml.Linq"
				# "WindowsBase")
		# RuntimeLibrary
		  # 0 (MultiThreaded) == /MT
		  # 1 (MultiThreadedDebug) == /MTd
		  # 2 (MultiThreadedDLL) == /MD
		  # 3 (MultiThreadedDebugDLL) == /MDd
		set_target_properties(${LIBRARYNAME} PROPERTIES COMPILE_FLAGS ${RUNTIMELIB})
	endif()
endmacro()