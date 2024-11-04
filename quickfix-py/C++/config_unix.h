/* src/C++/config_unix.h.  Generated from config_unix.h.in by configure.  */
/* src/C++/config_unix.h.in.  Generated from configure.ac by autoheader.  */

/* __gnu_cxx::bitmap_allocator exists */
/* #undef ENABLE_BITMAP_ALLOCATOR */

/* boost::fast_pool_allocator exists */
/* #undef ENABLE_BOOST_FAST_POOL_ALLOCATOR */

/* boost::pool_allocator exists */
/* #undef ENABLE_BOOST_POOL_ALLOCATOR */

/* __gnu_cxx::debug_allocator exists */
/* #undef ENABLE_DEBUG_ALLOCATOR */

/* __gnu_cxx::mt_allocator exists */
/* #undef ENABLE_MT_ALLOCATOR */

/* __gnu_cxx::new_allocator exists */
/* #undef ENABLE_NEW_ALLOCATOR */

/* __gnu_cxx::pool_allocator exists */
/* #undef ENABLE_POOL_ALLOCATOR */

/* tbb::scalable_allocator exists */
/* #undef ENABLE_TBB_ALLOCATOR */

/* The system has gethostbyname_r which takes a result as a pass-in param */
/* #undef GETHOSTBYNAME_R_INPUTS_RESULT */

/* custom allocator configured */
/* #undef HAVE_ALLOCATOR_CONFIG */

/* Define if you have boost framework */
/* #undef HAVE_BOOST */

/* Define if clock_gettime exists. */
#define HAVE_CLOCK_GETTIME 1

/* whether or not we have to demangle names */
/* #undef HAVE_CPLUS_DEMANGLE */

/* define if the compiler supports basic C++11 syntax */
#define HAVE_CXX11 1

/* define if the compiler supports basic C++14 syntax */
#define HAVE_CXX14 1

/* define if the compiler supports basic C++17 syntax */
#define HAVE_CXX17 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* found ftime */
#define HAVE_FTIME 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the 'compat' library (-lcompat). */
/* #undef HAVE_LIBCOMPAT */

/* Define to 1 if you have the 'c_r' library (-lc_r). */
/* #undef HAVE_LIBC_R */

/* Define to 1 if you have the 'nsl' library (-lnsl). */
/* #undef HAVE_LIBNSL */

/* Define to 1 if you have the 'pthread' library (-lpthread). */
/* #undef HAVE_LIBPTHREAD */

/* Define to 1 if you have the 'rt' library (-lrt). */
/* #undef HAVE_LIBRT */

/* Define to 1 if you have the 'socket' library (-lsocket). */
/* #undef HAVE_LIBSOCKET */

/* Define if you have sql library (-lmysqlclient) */
/* #undef HAVE_MYSQL */

/* Define if you have odbc library */
/* #undef HAVE_ODBC */

/* Define to 1 if you have the <openssl/ssl.h> header file. */
#define HAVE_OPENSSL_SSL_H 1

/* Define to 1 if PostgreSQL libraries are available */
/* #undef HAVE_POSTGRESQL */

/* Define if you have python3 */
/* #undef HAVE_PYTHON3 */

/* Define if you have ruby */
/* #undef HAVE_RUBY */

/* Define if you have SSL */
#define HAVE_SSL 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define if you have Intel TBB framework */
/* #undef HAVE_TBB */

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Name of package */
#define PACKAGE "quickfix"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "ask@quickfixengine.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "QuickFIX"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "QuickFIX 1.15.1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "quickfix"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.15.1"

/* select statement decrements timeval parameter if interupted */
/* #undef SELECT_MODIFIES_TIMEVAL */

/* Define to 1 if all of the C89 standard headers exist (not just the ones
   required in a freestanding environment). This macro is provided for
   backward compatibility; new code need not use it. */
#define STDC_HEADERS 1

/* For location of set_terminate */
#define TERMINATE_IN_STD 1

/* Whether or not we are using the new-style typeinfo header */
#define TYPEINFO_IN_STD 1

/* The system supports AT&T STREAMS */
/* #undef USING_STREAMS */

/* Version number of package */
#define VERSION "1.15.1"

/* enable reentrant system calls */
#define _REENTRANT 1

/* Define if clock_get_time exists. */
#define __MACH__ 1

/* socklen_t needs to be defined if the system doesn't define it */
/* #undef socklen_t */
