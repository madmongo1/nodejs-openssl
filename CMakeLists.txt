cmake_minimum_required(VERSION 3.0)
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS ON)

include (cmake/find_openssl_version.cmake)

if (NOT NODEJS_DEV_ROOT)
    message(FATAL_ERROR "NODEJS_DEV_ROOT not set")
endif ()

set(OPENSSL_INCLUDE_DIR ${NODEJS_DEV_ROOT}/include)
find_openssl_version(${OPENSSL_INCLUDE_DIR})

project(OpenSSL VERSION ${OPENSSL_PROJECT_VERSION} LANGUAGES CXX)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_library(ssl src/ssl.cpp)
add_library(crypto src/crypto.cpp)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")
set(INSTALL_MAN_DIR "${CMAKE_INSTALL_PREFIX}/share/man" CACHE PATH "Installation directory for manual pages")
set(INSTALL_PKGCONFIG_DIR "${CMAKE_INSTALL_PREFIX}/share/pkgconfig" CACHE PATH "Installation directory for pkgconfig (.pc) files")

include(CMakePackageConfigHelpers)

####
# Installation (https://github.com/forexample/package-example)

# Layout. This works for all platforms:
#   * <prefix>/lib/cmake/<PROJECT-NAME>
#   * <prefix>/lib/
#   * <prefix>/include/
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(targets_export_name "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

####
# Installation (https://github.com/forexample/package-example)

set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(targets_export_name "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

include(CMakePackageConfigHelpers)

# Note: PROJECT_VERSION is used as a VERSION
write_basic_package_version_file(
        "${version_config}" COMPATIBILITY SameMajorVersion
)

# Note: variable 'targets_export_name' used
#configure_file("cmake/Config.cmake.in" "${project_config}" @ONLY)

install(
        TARGETS ssl crypto
        EXPORT "${targets_export_name}"
        LIBRARY DESTINATION "lib"
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        INCLUDES DESTINATION "${include_install_dir}"
)

#install(
#        FILES "${project_config}" "${version_config}"
#        DESTINATION "${config_install_dir}"
#)

#install(
#        EXPORT "${targets_export_name}"
#        NAMESPACE "${namespace}"
#        DESTINATION "${config_install_dir}"
#)

install(DIRECTORY ${OPENSSL_INCLUDE_DIR}/openssl DESTINATION "${INSTALL_INC_DIR}")