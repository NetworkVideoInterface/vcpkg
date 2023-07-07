if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(FATAL_ERROR "Can't build BoringSSL if OpenSSL is installed. Please remove OpenSSL, and try to install BoringSSL again if you need it. Build will continue since BoringSSL is a drop-in replacement for OpenSSL")
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

vcpkg_find_acquire_program(GO)
get_filename_component(GO_EXE_PATH ${GO} DIRECTORY)
vcpkg_add_to_path(${GO_EXE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools INSTALL_TOOLS
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF ca1690e221677cea3fb946f324eb89d846ec53f2
  SHA512 1c12f6177d7e0902274e78f3686a18611c826a831cad80c7db970986756796eae5bff8c8684ce988ea573c970e9ef9decfedc6e3fc2ef6564772c2b7d0009514
  HEAD_REF chromium-stable
  PATCHES
    0001-vcpkg.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DINSTALL_HEADERS=OFF
    -DINSTALL_TOOLS=OFF
    # the FindOpenSSL.cmake script differentiates debug and release binaries using this suffix.
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenSSL)

include("${CMAKE_CURRENT_LIST_DIR}/install-pc-files.cmake")

if(IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/boringssl")
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/boringssl")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
