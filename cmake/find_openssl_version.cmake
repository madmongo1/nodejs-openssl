function(from_hex HEX DEC)
    string(TOUPPER "${HEX}" HEX)
    set(_res 0)
    string(LENGTH "${HEX}" _strlen)

    while (_strlen GREATER 0)
        math(EXPR _res "${_res} * 16")
        string(SUBSTRING "${HEX}" 0 1 NIBBLE)
        string(SUBSTRING "${HEX}" 1 -1 HEX)
        if (NIBBLE STREQUAL "A")
            math(EXPR _res "${_res} + 10")
        elseif (NIBBLE STREQUAL "B")
            math(EXPR _res "${_res} + 11")
        elseif (NIBBLE STREQUAL "C")
            math(EXPR _res "${_res} + 12")
        elseif (NIBBLE STREQUAL "D")
            math(EXPR _res "${_res} + 13")
        elseif (NIBBLE STREQUAL "E")
            math(EXPR _res "${_res} + 14")
        elseif (NIBBLE STREQUAL "F")
            math(EXPR _res "${_res} + 15")
        else ()
            math(EXPR _res "${_res} + ${NIBBLE}")
        endif ()

        string(LENGTH "${HEX}" _strlen)
    endwhile ()

    set(${DEC} ${_res} PARENT_SCOPE)
endfunction()

macro(find_openssl_version OPENSSL_INCLUDE_DIR)

    if (NOT EXISTS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h")
        message(FATAL_ERROR can't find openssl header file: "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h")
    endif ()

    file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" openssl_version_str
            REGEX "^#[\t ]*define[\t ]+OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])+.*")

    if (openssl_version_str)
        # The version number is encoded as 0xMNNFFPPS: major minor fix patch status
        # The status gives if this is a developer or prerelease and is ignored here.
        # Major, minor, and fix directly translate into the version numbers shown in
        # the string. The patch field translates to the single character suffix that
        # indicates the bug fix state, which 00 -> nothing, 01 -> a, 02 -> b and so
        # on.

        string(REGEX REPLACE "^.*OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F]).*$"
                "\\1;\\2;\\3;\\4;\\5" OPENSSL_VERSION_LIST "${openssl_version_str}")
        list(GET OPENSSL_VERSION_LIST 0 OPENSSL_VERSION_MAJOR)
        list(GET OPENSSL_VERSION_LIST 1 OPENSSL_VERSION_MINOR)
        from_hex("${OPENSSL_VERSION_MINOR}" OPENSSL_VERSION_MINOR)
        list(GET OPENSSL_VERSION_LIST 2 OPENSSL_VERSION_FIX)
        from_hex("${OPENSSL_VERSION_FIX}" OPENSSL_VERSION_FIX)
        list(GET OPENSSL_VERSION_LIST 3 OPENSSL_VERSION_PATCH)

        if (NOT OPENSSL_VERSION_PATCH STREQUAL "00")
            from_hex("${OPENSSL_VERSION_PATCH}" _tmp)
            # 96 is the ASCII code of 'a' minus 1
            math(EXPR OPENSSL_VERSION_PATCH_ASCII "${_tmp} + 96")
            unset(_tmp)
            # Once anyone knows how OpenSSL would call the patch versions beyond 'z'
            # this should be updated to handle that, too. This has not happened yet
            # so it is simply ignored here for now.
            string(ASCII "${OPENSSL_VERSION_PATCH_ASCII}" OPENSSL_VERSION_PATCH_STRING)
        endif ()

        set(OPENSSL_VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX}${OPENSSL_VERSION_PATCH_STRING}")
        set(OPENSSL_PROJECT_VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX}")
    endif ()
endmacro()