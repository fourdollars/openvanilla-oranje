#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([openvanilla-modules], [0.9.0a1], [http://github.com/lukhnos/openvanilla-oranje/issues])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL

# Checks for libraries.
AC_CHECK_LIB([sqlite3], [main])


# Checks for header files.
AC_HEADER_DIRENT
AC_HEADER_STDC
AC_CHECK_HEADERS([fcntl.h stdlib.h string.h sys/param.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_C_INLINE
AC_TYPE_SIZE_T
AC_STRUCT_TM

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_MEMCMP
AC_FUNC_MMAP
AC_FUNC_SELECT_ARGTYPES
AC_FUNC_STAT
AC_FUNC_REALLOC
AC_CHECK_FUNCS([bzero mkdir munmap rmdir select strcasecmp strchr strcspn strspn strstr strtol])


AC_CONFIG_FILES([
Frameworks/OpenVanilla/Headers/Makefile
Frameworks/OpenVanilla/Source/Makefile
Frameworks/OpenVanilla/Makefile
Frameworks/Makefile
Modules/OVIMGeneric/Makefile
Modules/OVIMPhonetic/Makefile
Modules/SharedLibrary/Makefile
Modules/Makefile
Makefile
])


AC_OUTPUT
