dnl custom mawk macros for autoconf
dnl
dnl The symbols beginning "CF_MAWK_" were originally written by Mike Brennan,
dnl renamed for consistency by Thomas E Dickey.
dnl 
dnl ---------------------------------------------------------------------------
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CC_FEATURES version: 1 updated: 2008/09/09 19:18:22
dnl -------------------
dnl Check compiler.
AC_DEFUN([CF_MAWK_CC_FEATURES],
[AC_MSG_CHECKING(compiler supports void*)
AC_TRY_COMPILE(
[char *cp ;
void *foo() ;] ,
[cp = (char*)(void*)(int*)foo() ;],void_star=yes,void_star=no)
AC_MSG_RESULT($void_star)
test "$void_star" = no && CF_MAWK_DEFINE2(NO_VOID_STAR,1)
AC_MSG_CHECKING(compiler groks prototypes)
AC_TRY_COMPILE(,[int x(char*);],protos=yes,protos=no)
AC_MSG_RESULT([$protos])
test "$protos" = no && CF_MAWK_DEFINE2(NO_PROTOS,1)
AC_C_CONST
test "$ac_cv_c_const" = no && CF_MAWK_DEFINE2(const)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_FPRINTF version: 1 updated: 2008/09/09 19:18:22
dnl ---------------------
dnl [sf]printf checks needed for print.c
dnl
dnl sometimes fprintf() and sprintf() are not proto'ed in stdio.h
AC_DEFUN([CF_MAWK_CHECK_FPRINTF],
[AC_EGREP_HEADER([[[^v]]fprintf],stdio.h,,CF_MAWK_DEFINE(NO_FPRINTF_IN_STDIO))
AC_EGREP_HEADER([[[^v]]sprintf],stdio.h,,CF_MAWK_DEFINE(NO_SPRINTF_IN_STDIO))])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_FUNC version: 3 updated: 2008/09/09 20:32:43
dnl ------------------
AC_DEFUN([CF_MAWK_CHECK_FUNC],[
    AC_CHECK_FUNC($1,,[
        CF_UPPER(cf_check_func,NO_$1)
        CF_MAWK_DEFINE($cf_check_func)])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_FUNCS version: 3 updated: 2008/09/09 20:32:43
dnl -------------------
AC_DEFUN([CF_MAWK_CHECK_FUNCS],[
for cf_func in $1
do
    CF_MAWK_CHECK_FUNC(${cf_func})
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_HEADER version: 3 updated: 2008/09/09 20:38:19
dnl --------------------
AC_DEFUN([CF_MAWK_CHECK_HEADER],[
    AC_CHECK_HEADER($1,,[
        CF_UPPER(cf_check_header,NO_$1)
        CF_MAWK_DEFINE($cf_check_header)])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_HEADERS version: 3 updated: 2008/09/09 20:32:43
dnl ---------------------
AC_DEFUN([CF_MAWK_CHECK_HEADERS],[
for cf_func in $1
do
    CF_MAWK_CHECK_HEADER(${cf_func})
done])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_LIMITS_MSG version: 1 updated: 2008/09/09 19:18:22
dnl ------------------------
dnl Write error-message if CF_MAWK_FIND_MAX_INT fails.
AC_DEFUN([CF_MAWK_CHECK_LIMITS_MSG],
[AC_MSG_ERROR(C program to compute maxint and maxlong failed.
Please send bug report to CF_MAWK_MAINTAINER.)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CHECK_SIZE_T version: 1 updated: 2008/09/09 19:18:22
dnl --------------------
dnl Find size_t.
AC_DEFUN([CF_MAWK_CHECK_SIZE_T],[
  [if test "$size_t_defed" != 1 ; then]
   AC_CHECK_HEADER($1,size_t_header=ok)
   [if test "$size_t_header" = ok ; then]
   AC_TRY_COMPILE([
#include <$1>],
[size_t *n ;
], [size_t_defed=1;
CF_MAWK_DEFINE2($2,1)
echo getting size_t from '<$1>'])
[fi;fi]])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CONFIG_H_HEADER version: 1 updated: 2008/09/09 19:18:22
dnl -----------------------
dnl Header for config.h
AC_DEFUN([CF_MAWK_CONFIG_H_HEADER],
[cat<<'EOF'
/* config.h -- generated by configure */
#ifndef CONFIG_H
#define CONFIG_H

EOF])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_CONFIG_H_TRAILER version: 1 updated: 2008/09/09 19:18:22
dnl ------------------------
dnl Footer for config.h
AC_DEFUN([CF_MAWK_CONFIG_H_TRAILER],
[cat<<'EOF'

#define HAVE_REAL_PIPES 1
#endif /* CONFIG_H */
EOF])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_DEFINE version: 2 updated: 2008/09/09 20:32:43
dnl --------------
dnl  I can't get AC_DEFINE_NOQUOTE to work so give up
AC_DEFUN([CF_MAWK_DEFINE],[AC_DEFINE($1)
echo  X $1 'ifelse($2,,1,$2)' >> defines.out])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_DEFINE2 version: 1 updated: 2008/09/09 19:18:22
dnl ---------------
AC_DEFUN([CF_MAWK_DEFINE2],
[echo  X '$1' '$2' >> defines.out])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_FIND_MAX_INT version: 1 updated: 2008/09/09 19:18:22
dnl --------------------
dnl Try to find a definition of MAX__INT from limits.h else compute.
AC_DEFUN([CF_MAWK_FIND_MAX_INT],
[AC_CHECK_HEADER(limits.h,limits_h=yes)
if test "$limits_h" = yes ; then :
else
AC_CHECK_HEADER(values.h,values_h=yes)
   if test "$values_h" = yes ; then
   AC_TRY_RUN(
[#include <values.h>
#include <stdio.h>
int main()
{   FILE *out = fopen("maxint.out", "w") ;
    if ( ! out ) exit(1) ;
    fprintf(out, "X MAX__INT 0x%x\n", MAXINT) ;
    fprintf(out, "X MAX__LONG 0x%lx\n", MAXLONG) ;
    exit(0) ; return(0) ;
}
], maxint_set=1,[CF_MAWK_CHECK_LIMITS_MSG])
   fi
if test "$maxint_set" != 1 ; then 
# compute it  --  assumes two's complement
AC_TRY_RUN(CF_MAWK_MAX__INT_PROGRAM,:,[CF_MAWK_CHECK_LIMITS_MSG])
fi
cat maxint.out >> defines.out ; rm -f maxint.out
fi ;])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_FIND_SIZE_T version: 1 updated: 2008/09/09 19:18:22
dnl -------------------
AC_DEFUN([CF_MAWK_FIND_SIZE_T],
[CF_MAWK_CHECK_SIZE_T(stddef.h,SIZE_T_STDDEF_H)
CF_MAWK_CHECK_SIZE_T(sys/types.h,SIZE_T_TYPES_H)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_FPE_SIGINFO version: 1 updated: 2008/09/09 19:18:22
dnl -------------------
dnl SYSv and Solaris FPE checks
AC_DEFUN([CF_MAWK_FPE_SIGINFO],
[AC_CHECK_FUNC(sigaction, sigaction=1)
AC_CHECK_HEADER(siginfo.h,siginfo_h=1)
if test "$sigaction" = 1 && test "$siginfo_h" = 1 ; then
   CF_MAWK_DEFINE(SV_SIGINFO)
else
   AC_CHECK_FUNC(sigvec,sigvec=1)
   if test "$sigvec" = 1 && ./fpe_check phoney_arg >> defines.out ; then :
   else CF_MAWK_DEFINE(NOINFO_SIGFPE)
   fi
fi])
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_GET_CONFIG_USER version: 1 updated: 2008/09/09 19:18:22
dnl -----------------------
dnl Input config.user
AC_DEFUN([CF_MAWK_GET_CONFIG_USER],
[cat < /dev/null > defines.out
test -f config.user && . ./config.user
CF_MAWK_SET_IF_UNSET(BINDIR,/usr/local/bin)
CF_MAWK_SET_IF_UNSET(MANDIR,/usr/local/man/man1)
CF_MAWK_SET_IF_UNSET(MANEXT,1)
echo "$USER_DEFINES" >> defines.out])
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_MAINTAINER version: 1 updated: 2008/09/09 19:18:22
dnl ------------------
AC_DEFUN([CF_MAWK_MAINTAINER], [brennan@whidbey.com])
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_MATHLIB version: 1 updated: 2008/09/09 19:18:22
dnl ---------------
dnl Look for math library.
AC_DEFUN([CF_MAWK_MATHLIB],[
if test "${MATHLIB+set}" != set  ; then
AC_CHECK_LIB(m,log,[MATHLIB=-lm ; LIBS="$LIBS -lm"],
[# maybe don't need separate math library
AC_CHECK_FUNC(log, log=yes)
if test "$log$" = yes
then
   MATHLIB='' # evidently don't need one
else
   AC_MSG_ERROR(
Cannot find a math library. You need to set MATHLIB in config.user)
fi])dnl
fi
AC_SUBST(MATHLIB)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_MAX__INT_PROGRAM version: 1 updated: 2008/09/09 19:18:22
dnl ------------------------
dnl C program to compute MAX__INT and MAX__LONG if looking at headers fails
AC_DEFUN([CF_MAWK_MAX__INT_PROGRAM],
[[#include <stdio.h>
int main()
{ int y ; long yy ;
  FILE *out ;

    if ( !(out = fopen("maxint.out","w")) ) exit(1) ;
    /* find max int and max long */
    y = 0x1000 ;
    while ( y > 0 ) y *= 2 ;
    fprintf(out,"X MAX__INT 0x%x\n", y-1) ;
    yy = 0x1000 ;
    while ( yy > 0 ) yy *= 2 ;
    fprintf(out,"X MAX__LONG 0x%lx\n", yy-1) ;
    exit(0) ;
    return 0 ;
 }]])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_OUTPUT_CONFIG_H version: 1 updated: 2008/09/09 19:18:22
dnl -----------------------
dnl Build config.h
AC_DEFUN([CF_MAWK_OUTPUT_CONFIG_H],
[# output config.h
rm -f config.h
(
CF_MAWK_CONFIG_H_HEADER
[sed 's/^X/#define/' defines.out]
CF_MAWK_CONFIG_H_TRAILER
) | tee config.h
rm defines.out])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_PROG_GCC version: 1 updated: 2008/09/09 19:18:22
dnl ----------------
dnl AC_PROG_CC with default -g to cflags
AC_DEFUN([CF_MAWK_PROG_GCC],
[AC_BEFORE([$0], [AC_PROG_CPP])dnl
AC_CHECK_PROG(CC, gcc, gcc, cc)
dnl
AC_MSG_CHECKING(whether we are using GNU C)
AC_CACHE_VAL(ac_cv_prog_gcc,
[dnl The semicolon is to pacify NeXT's syntax-checking cpp.
cat > conftest.c <<EOF
#ifdef __GNUC__
  yes;
#endif
EOF
if ${CC-cc} -E conftest.c 2>&AC_FD_CC | egrep yes >/dev/null 2>&1; then
  ac_cv_prog_gcc=yes
else
  ac_cv_prog_gcc=no
fi])dnl
AC_MSG_RESULT($ac_cv_prog_gcc)
rm -f conftest*
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_PROG_YACC version: 1 updated: 2008/09/09 19:18:22
dnl -----------------
dnl Which yacc.
AC_DEFUN([CF_MAWK_PROG_YACC],
[AC_CHECK_PROGS(YACC, byacc bison yacc)
test "$YACC" = bison && YACC='bison -y'])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_RUN_FPE_TESTS version: 1 updated: 2008/09/09 19:18:22
dnl ---------------------
dnl These are mawk's dreaded FPE tests.
AC_DEFUN([CF_MAWK_RUN_FPE_TESTS],
[if echo "$USER_DEFINES" | grep FPE_TRAPS_ON >/dev/null
then echo skipping fpe tests based on '$'USER_DEFINES
else
AC_TYPE_SIGNAL
[
echo checking handling of floating point exceptions
rm -f fpe_check
$CC $CFLAGS -DRETSIGTYPE=$ac_cv_type_signal -o fpe_check fpe_check.c $MATHLIB
if test -f fpe_check  ; then
   ./fpe_check 2>/dev/null
   status=$?
else 
   echo fpe_check.c failed to compile 1>&2
   status=100
fi

case $status in
   0)  ;;  # good news do nothing
   3)      # reasonably good news]
CF_MAWK_DEFINE(FPE_TRAPS_ON)
CF_MAWK_FPE_SIGINFO ;;

   1|2|4)   # bad news have to turn off traps
	    # only know how to do this on systemV and solaris
AC_CHECK_HEADER(ieeefp.h, ieeefp_h=1)
AC_CHECK_FUNC(fpsetmask, fpsetmask=1)
[if test "$ieeefp_h" = 1 && test "$fpsetmask" = 1 ; then]
CF_MAWK_DEFINE(FPE_TRAPS_ON)
CF_MAWK_DEFINE(USE_IEEEFP_H)
CF_MAWK_DEFINE2([TURN_ON_FPE_TRAPS()],
[fpsetmask(fpgetmask()|FP_X_DZ|FP_X_OFL)])
CF_MAWK_FPE_SIGINFO 
# look for strtod overflow bug
AC_MSG_CHECKING([strtod bug on overflow])
rm -f fpe_check
$CC $CFLAGS -DRETSIGTYPE=$ac_cv_type_signal -DUSE_IEEEFP_H \
	    -o fpe_check fpe_check.c $MATHLIB
if ./fpe_check phoney_arg phoney_arg 2>/dev/null
then 
   AC_MSG_RESULT([no bug])
else
   AC_MSG_RESULT([buggy -- will use work around])
   CF_MAWK_DEFINE2([HAVE_STRTOD_OVF_BUG],1)
fi

else
   [if test $status != 4 ; then]
      CF_MAWK_DEFINE(FPE_TRAPS_ON)
      CF_MAWK_FPE_SIGINFO 
    fi

    [case $status in
    1) 
cat 1>&2 <<'EOF'
Warning: Your system defaults generate floating point exception 
on divide by zero but not on overflow.  You need to 
#define TURN_ON_FPE_TRAPS() to handle overflow.
Please report this so I can fix this script to do it automatically.
EOF
;;
    2)
cat 1>&2 <<'EOF'
Warning: Your system defaults generate floating point exception 
on overflow  but not on divide by zero.  You need to 
#define TURN_ON_FPE_TRAPS() to handle divide by zero.
Please report this so I can fix this script to do it automatically.
EOF
;;
    4)
cat 1>&2 <<'EOF'
Warning: Your system defaults do not generate floating point
exceptions, but your math library does not support this behavior.
You need to
#define TURN_ON_FPE_TRAPS() to use fp exceptions for consistency.
Please report this so I can fix this script to do it automatically.
EOF
;;
    esac]
echo CF_MAWK_MAINTAINER
[echo You can continue with the build and the resulting mawk will be
echo useable, but getting FPE_TRAPS_ON correct eventually is best.
fi  ;;

  *)  # some sort of disaster
cat 1>&2 <<'EOF'
The program `fpe_check' compiled from fpe_check.c seems to have
unexpectly blown up.  Please report this to ]CF_MAWK_MAINTAINER.[
EOF
# quit or not ???
;;
esac 
rm -f fpe_check  # whew!!]
fi])
dnl ---------------------------------------------------------------------------
dnl CF_MAWK_SET_IF_UNSET version: 1 updated: 2008/09/09 19:18:22
dnl --------------------
dnl Set a variable if it is not set by configure script.
AC_DEFUN([CF_MAWK_SET_IF_UNSET],
[test "[$]{$1+set}" = set || $1="$2"
AC_SUBST($1)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_UPPER version: 5 updated: 2001/01/29 23:40:59
dnl --------
dnl Make an uppercase version of a variable
dnl $1=uppercase($2)
AC_DEFUN([CF_UPPER],
[
$1=`echo "$2" | sed y%abcdefghijklmnopqrstuvwxyz./-%ABCDEFGHIJKLMNOPQRSTUVWXYZ___%`
])dnl
