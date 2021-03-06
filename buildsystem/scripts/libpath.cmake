
if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
	set(DEP_LIBS "${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/debug/libprotocd.lib"
				"${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/debug/libprotobufd.lib"
				"${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/debug/libprotobuf-lited.lib"
				 )
else()
	set(DEP_LIBS "${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/release/libprotoc.lib"
				"${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/release/libprotobuf.lib"
				"${CMAKE_CURRENT_SOURCE_DIR}/../../serializedata/address/source/lib/release/libprotobuf-lite.lib"
				)
endif()