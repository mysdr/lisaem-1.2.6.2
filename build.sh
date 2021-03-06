#!/bin/bash

#### Edit these options for your system

WITHDEBUG=""             # -g for debugging, -p for profiling. -pg for both
#STATIC=--static
WITHOPTIMIZE="-O2 -ffast-math -fomit-frame-pointer"
WITHUNICODE="--unicode=no"

#if compiling for win32, edit WXDEV path to specify the
#location of wxDev-CPP 6.10 (as a cygwin, not windows path.)
#i.e. WXDEV=/cygdrive/c/wxDEV-Cpp
#if left empty, code below will try to locate it, so only set this
#if you've installed it in a different path than the default.

#WXDEV=""


########################################################################
 VERSION="1.2.6.2-RELEASE_2015.09.04"
#VERSION="1.2.6.1-RELEASE_2012.12.12"
#VERSION="1.2.6-RELEASE_2007.12.12"
#VERSION="1.2.5-RELEASE_2007.11.25"
#VERSION="1.2.2-RELEASE_2007.11.11"
#VERSION="1.2.0-RELEASE_2007.09.23"
#VERSION="1.0.1-DEV_2007.08.13"
#VERSION="1.0.0-RELEASE_2007.07.07"
#VERSION="1.0.0-RC2_2007.06.27"

for i in bin resources lisa wxui generator cpu68k
do
 if [ ! -d ./$i ]
 then
   echo "Please run this script from the top level directory. i.e."
   echo
   echo "tar xjpvf lisaem-$VERSION.tar.bz2"
   echo "cd lisaem-$VERSION"
   echo "./build.sh $@"
   exit 1
 fi
done

# sometimes $CYGWIN is not defined, shit happens, ramma ramma ding dong, deal with it.
[ -n "`uname | grep CYGWIN`" ] && [ -z "$CYGWIN" ] && CYGWIN="`uname | grep CYGWIN`";


if [ -z "$CYGWIN" ];
then
 [ "`uname`" == "CYGWIN_NT-5.0" ] && CYGWIN="`uname`"
fi


if [ -n "$CYGWIN" ]
then

STATIC=--static
WITHBLITS="-DUSE_RAW_BITMAP_ACCESS"

 if [ -z "$WXDEV" ]
 then
     if [ -f /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/wx-devcpp/Install_Dir ]
     then
        WXWINPATH="`cat /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/wx-devcpp/Install_Dir`"
        WXDEV=`cygpath "$WXWINPATH"`
     fi
 fi


 #z is first drive because that's how I have it on my machine. :-)
 #c is the most common path of course.
 export EXT=".exe"

 if [ -z "$WXDEV" ]
 then
   [ -d "/cygdrive/z/wxDev-Cpp" ] && export WXDEV="/cygdrive/z/wxDev-Cpp"
   [ -d "/cygdrive/c/wxDev-Cpp" ] && export WXDEV="/cygdrive/c/wxDev-Cpp"
 fi

 # if we still haven't found what we're looking for, look everywhere else
 if [ -z "$WXDEV" ]
 then
  for i in c d e f g h i j k l m n o p q r s t u v w x y z;
  do
   if [ -z "$WXDEV" ]; then
      [ -d "/cygdrive/${i}/wxDev-Cpp"               ] && export WXDEV="/cygdrive/${i}/wxDev-Cpp"
      [ -d "/cygdrive/${i}/Program Files/wxDev-Cpp" ] && export WXDEV="/cygdrive/${i}/Program Files/wxDev-Cpp"
      [ -d "/cygdrive/${i}/Program Files/Dev-Cpp"   ] && export WXDEV="/cygdrive/${i}/Program Files/Dev-Cpp"
   fi
  done
 fi

 if [ -z "$WXDEV" ]
 then
  echo "Could not find the wxDev C++ 6.10 Environment.  Please download and install it"
  echo "from http://wxdsgn.sourceforge.net/  and install it to C:\\wxDev-Cpp"
  echo "and yes, I did look on every drive for it!"
  exit 1
 fi

 ARCHITECTURE=i586
 #ARCHITECTURE=pentium
 #ARCHITECTURE=pentium4
 #ARCHITECTURE=opteron

 FAILED=0
 [ -z "`/bin/grep -i 'IniVersion=6.10' ${WXDEV}/devcpp.pallete`" ]
 [ -f "${WXDEV}/devcpp.exe" ] || FAILED=1

  if [ $FAILED -eq 0 ]
  then

   export MINGW="${WXDEV}/lib/gcc/mingw32/3.4.2"
   export MINGCPP="${WXDEV}/include/c++/3.4.2"
   export PATH=${WXDEV}/bin:${MINGW}/libexec:${MINGW}/bin/:${PATH}
   export CXXINC="-I ${MINGW}/include  -I ${MINGCPP}/backward  -I ${MINGCPP}/mingw32  -I ${MINGCPP}  -I ${WXDEV}/include  -I ${WXDEV}/  -I ${WXDEV}/include/common/wx/msw  -I ${WXDEV}/include/common/wx/generic  -I ${WXDEV}/include/common/wx/fl  -I ${WXDEV}/include/common/wx/gizmos  -I ${WXDEV}/include/common/wx/html  -I ${WXDEV}/include/common/wx/mmedia  -I ${WXDEV}/include/common/wx/net  -I ${WXDEV}/include/common/wx/ogl  -I ${WXDEV}/include/common/wx/plot  -I ${WXDEV}/include/common/wx/protocol  -I ${WXDEV}/include/common/wx/stc  -I ${WXDEV}/include/common/wx/svg  -I ${WXDEV}/include/common/wx/xml  -I ${WXDEV}/include/common/wx/xrc  -I ${WXDEV}/include/common/wx  -I ${WXDEV}/include/common"
   export CXXDEFS="  -D__WXMSW__ -D__GNUWIN32__ -D__WIN95__ -fno-rtti -fno-exceptions -fno-pcc-struct-return -fstrict-aliasing $WARNINGS -D__WXMSW__ -D__GNUWIN32__ -D__WIN95__   -fexpensive-optimizations -O3"
   export LIBS="-L `cygpath -wp ${WXDEV}/Lib` -L `cygpath -wp ${WXDEV}/Lib/gcc/mingw32/3.4.2/`  -mwindows -lwxmsw28 -lwxmsw28_gl -lwxtiff -lwxjpeg -lwxpng -lwxzlib -lwxregex -lwxexpat -lkernel32 -luser32 -lgdi32 -lcomdlg32 -lwinspool -lwinmm -lshell32 -lcomctl32 -lole32 -loleaut32 -luuid  -ladvapi32 -lwsock32 -lopengl32"
   export INCS="-I. -I..\\wxui -I ..\\cpu68k -I ..\include -I `cygpath -wp $WXDEV/Include` -I `cygpath -wp $WXDEV/include/common`"
   export OPTS="-D__WXMSW__ -O3 -ffast-math -fomit-frame-pointer -march=$ARCHITECTURE -malign-double -falign-loops=5 -falign-jumps=5 -falign-functions=5 -I ..\cpu68k -I ..\\include -I . -I.. -I `cygpath -wp $WXDEV/include` -I `cygpath -wp $MING/include` -I `cygpath -wp $WXDEV/Include` -I `cygpath -wp $WXDEV/include/common`"

   export RCINCS="--include-dir=`cygpath -wp ${WXDEV}/include/common` "
   export DEFINES="-D__WXMSW__ -D__GNUWIN32__ -D__WIN95__ -D __WIN32__"
   export CXXINCS="-I. -I ..\include -I ..\cpu68k -I ..\\wxui -I `cygpath -wp ${MINGW}/include`  -I `cygpath -wp ${MINGCPP}/backward`  -I `cygpath -wp ${MINGCPP}/mingw32`  -I `cygpath -wp ${MINGCPP}`  -I `cygpath -wp ${WXDEV}/include`  -I `cygpath -wp ${WXDEV}/`  -I `cygpath -wp ${WXDEV}/include/common/wx/msw`  -I `cygpath -wp ${WXDEV}/include/common/wx/generic`  -I `cygpath -wp ${WXDEV}/include/common/wx/fl`  -I `cygpath -wp ${WXDEV}/include/common/wx/gizmos`  -I `cygpath -wp ${WXDEV}/include/common/wx/html`  -I `cygpath -wp ${WXDEV}/include/common/wx/mmedia`  -I `cygpath -wp ${WXDEV}/include/common/wx/net`  -I `cygpath -wp ${WXDEV}/include/common/wx/ogl`  -I `cygpath -wp ${WXDEV}/include/common/wx/plot`  -I `cygpath -wp ${WXDEV}/include/common/wx/protocol`  -I `cygpath -wp ${WXDEV}/include/common/wx/stc`  -I `cygpath -wp ${WXDEV}/include/common/wx/svg`  -I `cygpath -wp ${WXDEV}/include/common/wx/xml`  -I `cygpath -wp ${WXDEV}/include/common/wx/xrc`  -I `cygpath -wp ${WXDEV}/include/common/wx`  -I `cygpath -wp ${WXDEV}/include/common`"
   export CXXFLAGS="${CXXINCS} ${DEFINES}"
   export CXXFLAGS="-Wno-write-strings ${CXXINCS} ${DEFINES}"  #2015.08.30 allow GCC 4.6.3 to ignore constant violation
   export CFLAGS="${INCS} ${DEFINES} -fno-exceptions -fno-pcc-struct-return -fstrict-aliasing $WARNINGS -Wno-format -Wno-unused -D__WXMSW__ -D__GNUWIN32__ -D__WIN95__   -fexpensive-optimizations -O3"
   export GPROF=gprof.exe
   export RM="rm -f"
   export LINK=g++.exe
   export CC=gcc.exe
   export CPP=g++.exe
   export CXX=g++.exe
   #export CFLAGS=$OPTS
   LINKOPTS="-static $LIBS"

   if [ -z "`gcc.exe --version | grep -i ming`" ]
   then
     echo The gcc.exe compiler does not seem to be the mingw version.
     exit 1
   fi
   if [ -z "`g++.exe --version | grep -i ming`" ]
   then
     echo The g++.exe compiler does not seem to be the mingw version.
     exit 1
   fi

 else

  echo "Could not find the wxDev C++ 6.10-2 Environment.  Please download and install it"
  echo "from http://wxdsgn.sourceforge.net/  and install it in c:\\wxDev-Cpp"
  echo "and not in C:\\Program Files\wxDev-Cpp as that will cause problems with the build."
  echo
  echo "If you did install it, perhaps it is the wrong version?"

  exit 1
 fi
else

WXVER=0
case "`wx-config --version`" in
  3*)
        echo WARNING: wxWidgets versions higher than 2.8 have not been tested.
        echo It might work if they are compiled with backwards compatibility.
        ;;
  2.9*|2.8*) ;;
  *)    echo Could not find wxWidgets 2.8.0 or higher.
        echo Please install it and ensure that wx-config is in the path
        exit 1
  ;;
esac


fi
#$CYGWIN is pre-set.  Cache $DARWIN so we don't have to call uname over and over.
[ "`uname`" == "Darwin" ] && DARWIN="Darwin"


# not needed on OS X
if [ -z "$DARWIN" ]
then
  if [ -z "`which pngtopnm`" ]
  then
    echo Could not find pngtopnm which is part of the netpbm package.
    echo this program is required.  Please install the netpbm package,
    echo then run this script again.
    exit 1
  fi
else
  # On OS X, we want to use rawbits
  WITHBLITS="-DUSE_RAW_BITMAP_ACCESS"
fi

# change default to unicode if we find a unicode enabled build - user can update this explicitly.
# purpose of this is to avoid errors on systems that have only unicode.
if [ -z "$CYGWIN" ]
then
  WXREL="`wx-config --release`"
  if [ -n "`wx-config --list | grep $WXREL | grep unicode`" ]
  then
    WITHUNICODE="--unicode=yes"
  fi
fi


if [ -z "$PREFIX" ]
then
  if [ -n "$DARWIN" ];
  then
    PREFIX="/Applications"
    PREFIXLIB="/Library"
  else
      if [ -n "$CYGWIN" ]
      then
         PREFIX="/cygdrive/c/Program Files/Sunder.NET/LisaEm"
         PREFIXLIB="/cygdrive/c/Program Files/Sunder.NET/LisaEm"
      else
         PREFIX="/usr/local/bin"
         PREFIXLIB="/usr/local/share/"
      fi
  fi
fi



##############################################################################
#To compile or not to compile.
#
#if the .o file exists, compare it to the .c
#
# $1 - source file.
# $2 - object file.
#
# if the object file does not exist, it will return true.
# if the object is older than the source, it will return true.
##############################################################################

function NEEDED()
{
 if [ -f $2 ]
 then
   [ "`ls -tr $2 $1 2>/dev/null| tail -1`" == "$1" ] && return 0
   return 1
 fi
 return 0
}

# turn this on by default.

echo
echo '----------------------------------------------------------------'
echo '     Apple Lisa 2 Emulator   -    Unified Build Script'
echo "                  LisaEm  $VERSION"
echo '                   http://lisaem.sunder.net'
echo '  Copyright (C) 2007 Ray A. Arachelian, All Rights Reserved'
echo 'Released under the terms of the GNU General Public License 2.0'
echo '----------------------------------------------------------------'

# Check our directories
ERROR=""
for i in lisa wxui include generator cpu68k
do
 [ -d "$i" ] || ERROR="$ERROR $i"
done

if [ -n "$ERROR" ]
then
 echo I could not find one or more of my directories:
 echo $ERROR
 echo Please make sure that you are running this script while inside
 echo the top lisaem directory, and that your download and extraction
 echo of the source code was complete.
 exit 1
fi


# Parse command line options if any, overriding defaults.

for i in $@
do

 case "$i" in
  clean)
            echo Removing binaries
            rm -f .last-opts last-opts
            cd ./lisa       && /bin/rm -rf ../bin/* *.a *.o *.exe
            cd ../resources && /bin/rm -f *.bmp *.wav.c lisaem_private.res floppy?.xpm lisaface?.xpm power_off.xpm power_on.xpm
            cd ../generator && /bin/rm -f *.a *.o
            cd ../wxui      && /bin/rm -f *.a *.o
            cd ../cpu68k    && /bin/rm -f *.a *.o *.exe def68k gen68k cpu68k-?.c
            cd ../include   && /bin/rm -f built_by.h
            cd ..
            echo clean done.
            #if we said clean install or clean build, then do not quit
            Z="`echo $@ | grep -i install``echo $@ | grep -i build`"
            [ -z "$Z" ] && exit 0

  ;;
 build*)    echo ;;    #default - nothing to do here, this is the default.
 install)   
            [ -z "$CYGWIN" ] && [ "`whoami`" != "root" ] && echo "Need to be root to install. try sudo ./build.sh $@" && exit 1
            INSTALL=1;
            ;;

 uninstall)
           if [ -n "$DARWIN" ];
           then
             echo Uninstall commands not yet implemented.
             exit 1
           fi

           if [ -n "$CYGWIN" ];
           then
              [ -n "$PREFIX" ]    && echo Deleting $PREFIX    && rm -rf $PREFIX
              [ -n "$PREFIXLIB" ] && echo Deleting $PREFIXLIB && rm -rf $PREFIXLIB
              exit 0
           fi

           #Linux, etc.

           #PREFIX="/usr/local/bin"
           #PREFIXLIB="/usr/local/share/"

           echo Uninstalling from $PREFIX and $PREFIXLIB
           rm -rf $PREFIXLIB/lisaem/
           rm -f  $PREFIX/lisaem
           rm -f  $PREFIX/lisafsh-tool
           rm -f  $PREFIX/lisadiskinfo
           exit 0

    ;;

 --without-debug)          WITHDEBUG=""                         ;;
 --with-debug)             WITHDEBUG="$WITHDEBUG -g"            
                           WARNINGS="-Wall"                    ;;
 --with-profile)           WITHDEBUG="$WITHDEBUG -p"            ;;
 --with-static)            STATIC="-static"                     ;;
 --without-static)         STATIC=""                            ;;
 --without-optimize)       WITHOPTIMIZE=""                      ;;
 --with-tracelog)          WITHTRACE="-DDEBUG -DTRACE"        
                           WARNINGS="-Wall"                    ;;
 --with-unicode)           WITHUNICODE="--unicode=yes"          ;;
 --without-unicode)        WITHUNICODE="--unicode=no"           ;;
 --without-upx)            WITHOUTUPX="noupx"                   ;;

# no longer used.
# --with-direct-blits)      WITHBLITS="-DDIRECT_BLITS"           ;;
# --without-direct-blits)   WITHBLITS="-DNO_DIRECT_BLITS"        ;;
 --with-rawbitmap)         WITHBLITS="-DUSE_RAW_BITMAP_ACCESS"  ;;
 --without-rawbitmap)      WITHBLITS="-DNO_RAW_BITMAP_ACCESS"   ;;
 --with-wxui)              WITHWXUI="wxui"                      ;;
 --without-wxui)           WITHWXUI=""                          ;;
 *)                        UNKNOWNOPT="$UNKNOWNOPT $i"          ;;
 esac

done



if [ -n "$UNKNOWNOPT" ]
then
 echo
 echo "Unknown options $UNKNOWNOPT"
 cat <<ENDHELP

Commands:
 clean                 Removes all compiled objects, libs, executables
 build                 Compiles lisaem (default)
 clean build           Remove existing objects, compile everything cleanly
 install               Not yet implemented on all platforms
 uninstall             Not yet implemented on all platforms

Options:
--without-debug        Disables debug and profiling
--with-debug           Enables symbol compilation
--with-tracelog        Enable tracelog (needs debug on, not on win32)

--with-static          Enables a static compile
--without-static       Enables shared library compile (not recommended)
--without-optimize     Disables optimizations
--without-upx          Disables UPX compression (no upx on OS X)

--with-rawbitmap       Raw bitmap access - high video performance 
                       (OS X only, doesn't work properly elsewhere)
--without-rawbitmap    Disables Raw bitmap access, uses wxImage::SetRGB instead
					   (default for non-OS X)
--with-unicode         Ask wx-config for a unicode build (might not yet work)
--without-unicode      Ask wx-config for a non-unicode build (default)

Environment Variables you can pass:

CC                     Path to C Compiler
CPP                    Path to C++ Compiler
WXDEV                  Cygwin Path to wxDev-CPP 6.10 (win32 only)
PREFIX                 Installation directory

ENDHELP
exit 1

fi

# create built by info and license
BUILTBY="\"Compiled on `date` by $LOGNAME@`uname -n`  (`uname -v `)\n options:$WITHBLITS $WITHDEBUG $WITHTRACE $WITHUNICODE\""
echo "#define BUILTBY $BUILTBY" >./include/built_by.h
echo -n "#define LICENSE "    >>./include/built_by.h
cat LICENSE | sed 's/^/"/g' | sed 's/$/\\n"      \\/g' >>./include/built_by.h
echo >>./include/built_by.h
echo >>./include/built_by.h

# allow versions of LisaEm compiled under Linux, *BSD, etc. to run as compiled
# without being installed.  (Some versions of wxWidgets look for the lowercase name, others, upper)
cd share
ln -sf ../resources lisaem
ln -sf ../resources LisaEm
cd ..

[ -n "${WITHDEBUG}${WITHTRACE}" ] && if [ -n "$INSTALL" ];
then
   echo "Warning, will not install since debug/profile/trace options are enabled"
   echo "as Install command is only for production builds."
   INSTALL=""
fi

if NEEDED include/vars.h lisa/unvars.c
then
cd ./lisa

echo Creating unvars.c
cat <<END1 >unvars.c
/**************************************************************************************\\
*                             Apple Lisa 2 Emulator                                    *
*                                                                                      *
*              The Lisa Emulator Project  V1.0.0      REL 2007.07.07                   *
*                  Copyright (C) 2007 Ray A. Arachelian                                *
*                            All Rights Reserved                                       *
*                                                                                      *
*                        Reset Global Variables .c file                                *
*                                                                                      *
*            This is a stub file - actual variables are in vars.h.                     *
*        (this is autogenerated by the build script. do not hand edit.)                *
\**************************************************************************************/

#define IN_UNVARS_C 1
// include all the includes we'll (might) need (and want)
#include "vars.h"

#define REASSIGN(  a , b  , c  )  {(b) = (c);}

void unvars(void)
{

#undef GLOBAL
#undef AGLOBAL
#undef ACGLOBAL

END1
egrep 'GLOBAL\(' ../include/vars.h | grep -v '*' | grep -v AGLOBAL | grep -v '#define' | grep -v FILE | grep -v get_exs | grep -v '\[' | sed 's/GLOBAL/REASSIGN/g'  >>unvars.c

echo "}" >> unvars.c

cd ..
fi

#if we're not on Cygwin, then setup the defaults, unless
#they were defined already from the parent shell.
if [ -z "$CYGWIN" ]
then
 # many thanks to David Cecchin for finding the unicode issues fixed below.

 WXCONFIGFLAGS=`wx-config  --cppflags $WITHUNICODE `
 if [ -z "$WXCONFIGFLAGS" ]
 then
    echo wx-config has failed, or returned an error.  Ensure that it exists in your path.
    which wx-config
    exit 3
 fi
#2015.08.31 
 #CFLAGS="-Wwrite-strings -I. -I../include -I../cpu68k -I../wxui $WXCONFIGFLAGS $WITHOPTIMIZE $WITHDEBUG"
 CFLAGS="-Wno-write-strings -I. -I../include -I../cpu68k -I../wxui $WXCONFIGFLAGS $WITHOPTIMIZE $WITHDEBUG"
 CXXFLAGS="-Wno-write-strings -I. -I../include -I../cpu68k -I../wxui $WXCONFIGFLAGS $WITHOPTIMIZE $WITHDEBUG"
 LINKOPTS="`wx-config $STATIC  $WITHUNICODE  --libs --linkdeps --cppflags`"
 if [ -z "$LINKOPTS" ]
 then
    echo wx-config has failed, or returned an error.  Ensure that it exists in your path.
    which wx-config
    exit 3
 fi

 [ -z "$CC" ] && CC=gcc
 [ -z "$CXX" ] && CXX=g++
 [ -z "$GPROF" ] && GPROF=gprof
fi

###########################################################################

# Has the configuration changed since last time? if so we may need to do a clean build.
[ -f .last-opts ] && source .last-opts

needclean=0
#debug and tracelog changes affect the whole project, so need to clean it all
if [ "$WITHTRACE" != "$LASTTRACE" ]; then needclean=1; fi;
if [ "$WITHDEBUG" != "$LASTDEBUG" ]; then needclean=1; fi;
# display mode changes affect only the main executable.
if [ "$WITHBLITS" != "$LASTBLITS" ]; then rm -rf ./lisa/lisaem_wx.o ./lisa/lisaem ./lisa/lisaem.exe ./lisa/LisaEm.app; fi;

if [ "$needclean" -gt 0 ]
then

cd ./lisa
/bin/rm -f *.a *.o *.exe lisaem lisaem.exe lisaem_private.res
/bin/rm -rf LisaEm.app
cd ../generator
/bin/rm -f *.a *.o
cd ../wxui
/bin/rm -f *.a *.o
cd ../cpu68k
/bin/rm -f *.a *.o *.exe def68k gen68k cpu68k-?.c
cd ..
	
fi


# hack for Snow and above: - SIXTYFOURBITS is expected to be null here.
if [ -n "$DARWIN" ]
then
   if [ -n "$SIXTYFOURBITS" ]
   then
     echo 64 bit
     CFLAGS="$CFLAGS -arch x86_64 -m64"
     CPPFLAGS="$CFLAGS -arch x86_64 -m64"
     CXXFLAGS="$CXXFLAGS -arch x86_64 -m64"
     LDFLAGS="-arch x86_64 -m64"
   else
     echo 32 bit
     CFLAGS="$CFLAGS -arch i386 -m32"
     CPPFLAGS="$CPPFLAGS -arch i386 -m32"
     CXXFLAGS="$CXXFLAGS -arch i386 -m32"
     LDFLAGS="-arch i386 -m32"
   fi
fi


echo "LASTTRACE=\"$WITHTRACE\""  > .last-opts
echo "LASTDEBUG=\"$WITHDEBUG\""  >>.last-opts
echo "LASTBLITS=\"$WITHBLITS\""  >>.last-opts

###########################################################################
echo Building...
echo
echo "* Generator CPU Core OpCodes   (./cpu68k)"

cd cpu68k

DEPS=0
[ "$DEPS" -eq 0 ] && if NEEDED def68k-iibs.h          lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED def68k.def             lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED gen68k.c               lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED tab68k.c               lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED def68k.c               lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED ../include/vars.h      lib68k.a; then  DEPS=1;fi
[ "$DEPS" -eq 0 ] && if NEEDED ../include/generator.h lib68k.a; then  DEPS=1;fi


if [ "$DEPS" -gt 0 ]
then

for src in tab68k.c def68k.c; do
    echo "  Compiling $src..."
    $CC $CFLAGS -c $WITHDEBUG $WITHTRACE $src || exit 1
done

$CC $LDFLAGS -o def68k tab68k.o def68k.o

echo -n "  "
./def68k || exit 1

echo "  Compiling gen68k.c..."
$CC $WITHDEBUG $WITHTRACE $CFLAGS -c gen68k.c || exit 1

$CC $CFLAGS -o gen68k tab68k.o gen68k.o
echo -n "  "
./gen68k || exit 1

#          1         2         3         4         5         6         7
#01234567890123456789012345678901234567890123456789012345678901234567890123456789
#  Writing C files... 0. 1. 2. 3. 4. 5. 6. 7. 8. 9. a. b. c. d. e. f. done.

echo -n "  Compiling cpu68k-: "
for src in 0 1 2 3 4 5 6 7 8 9 a b c d e f; do
    echo -n "${src}. "
    $CC $WITHDEBUG $WITHTRACE $CFLAGS  -c cpu68k-${src}.c || exit 1
done
echo "done."

rm -f lib68k.a

# [0-9a-f] doesn't always work in some of the weirder systems.
for i in 0 1 2 3 4 5 6 7 8 9 a b c d e f
 do
  ARLIST="$ARLIST cpu68k-${i}.o"
 done

ar cru lib68k.a $ARLIST || exit 1
ranlib lib68k.a || exit 1

fi

###########################################################################

#Build libgenerator.a
echo
echo "* Generator CPU Library        (./generator)"
cd ../generator

DEPS=0
[ "$DEPS" -eq 0 ] && if  NEEDED ../include/vars.h  libgenerator.a;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if  NEEDED cpu68k.c           libgenerator.a;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if  NEEDED reg68k.c           libgenerator.a;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if  NEEDED diss68k.c          libgenerator.a;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if  NEEDED ui_log.c           libgenerator.a;then  DEPS=1; fi

if [ "$DEPS" -gt 0 ]
then
for src in cpu68k reg68k ui_log diss68k; do
    #only compile what we need, unlike ./cpu68k this is less sensitive
    if NEEDED ${src}.c ${src}.o
    then
      echo "  Compiling ${src}.c..."
      $CC $WITHDEBUG $WITHTRACE $CFLAGS -c ${src}.c || exit 1
    fi
done
ar cru libgenerator.a cpu68k.o reg68k.o ui_log.o diss68k.o ../cpu68k/tab68k.o || exit 1
ranlib libgenerator.a || exit 1

fi
###########################################################################

echo
echo "* LisaEm and support tools     (./lisa)"
cd ../lisa

# Compile C
for i in libdc42 floppy profile unvars vars glue fliflo_queue cops zilog8530 via6522 irq mmu rom romless memory symbols
do

	LIST="$LIST $i.o"

  DEPS=0
  [ "$DEPS" -eq 0 ] && if NEEDED ../include/vars.h  ${i}.o;then DEPS=1; fi
  [ "$DEPS" -eq 0 ] && if NEEDED ${i}.c             ${i}.o;then DEPS=1; fi
  if [ "$DEPS" -gt 0 ]
  then
     echo "  Compiling ${i}.c..."
     $CC -W $WARNINGS -Wstrict-prototypes -Wno-format -Wno-unused  $WITHDEBUG $WITHTRACE $CFLAGS -c ${i}.c -o ${i}.o || exit 1
  fi
done

DEPS=0
[ "$DEPS" -eq 0 ] && if NEEDED lisadiskinfo.c ../bin/lisadiskinfo;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if NEEDED libdc42.o      ../bin/lisadiskinfo;then  DEPS=1; fi
if [ "$DEPS" -gt 0 ]
then
  echo "  Linking ./bin/lisadiskinfo..."
  $CC $CFLAGS $LDFLAGS -o ../bin/lisadiskinfo lisadiskinfo.c libdc42.o || exit 1
  if [ -z "$WITHDEBUG" ]
  then
    strip ../bin/lisadiskinfo${EXT}
    if  [ -z "$WITHOUTUPX"                 ]; then
     if [ -x "`which upx 2>/dev/null`"     ]; then upx --best ../bin/lisadiskinfo${EXT} ; fi
    fi

   fi
fi



DEPS=0
[ "$DEPS" -eq 0 ] && if NEEDED lisafsh-tool.c ../bin/lisafsh-tool;then  DEPS=1; fi
[ "$DEPS" -eq 0 ] && if NEEDED libdc42.o      ../bin/lisafsh-tool;then  DEPS=1; fi
if [ "$DEPS" -gt 0 ]
then
  echo "  Linking ./bin/lisafsh-tool..."
  $CC $CFLAGS -o ../bin/lisafsh-tool lisafsh-tool.c libdc42.o || exit 1
  if [ -z "$WITHDEBUG" ]
  then
    strip ../bin/lisafsh-tool${EXT}
    if  [ -z "$WITHOUTUPX"                 ]; then
     if [ -x "`which upx 2>/dev/null`"     ]; then upx --best ../bin/lisafsh-tool${EXT} ; fi
    fi
   fi
fi




VSTATIC=0

# If we're on the evilOS, we use COFF resources, and the images are BMP's
echo
echo "* LisaEm Resources             (./resources)"
cd ../resources

if [ -n "$CYGWIN" ]
then
 for i in floppy0 floppy1 floppy2 floppy3 floppyN lisaface0 lisaface1 lisaface2 lisaface3 power_off power_on
 do
   if NEEDED ${i}.png ${i}.bmp
   then
        echo Generating ${i}.bmp...
        pngtopnm  < ${i}.png | ppmtobmp -windows -bpp=8 -quiet > ${i}.bmp
        VSTATIC=1
   fi

 done
fi

# If we're on Mac OS X, we use the Resources directory rather than embedded XPM's.
# on Linux, *BSD, we use PNG's in the /usr/local/share/lisaem directory.
# so we can skip the XPM generation.  On windows, it's BMP's, so this is only for X11/GTK builds

### if [ -z "${CYGWIN}${DARWIN}" ]
### then
###     for i in floppy0 floppy1 floppy2 floppy3 floppyN lisaface0 lisaface1 lisaface2 lisaface3 power_off power_on
###     do
###        if NEEDED ${i}.png ${i}.xpm
###        then
###            echo Generating ${i}.xpm...
###            pngtopnm  < ${i}.png | ppmtoxpm -quiet -name ${i}_xpm | sed -e's/^static //' > ${i}.xpm
###        fi
###     done
### fi

cd ../lisa

if [ "$VSTATIC" -gt 0 ]; then DEPS=1; else DEPS=0; fi
[ "$DEPS" -eq 0 ] && if NEEDED lisaem_static_resources.cpp lisaem_static_resources.o; then DEPS=1; fi

if [ "$DEPS" -gt 0 ]
then
  echo "  Compiling lisaem_static_resources.cpp..."
  $CXX $CFLAGS -c lisaem_static_resources.cpp -o lisaem_static_resources.o || exit 1
fi
LIST="$LIST lisaem_static_resources.o"

if [ -n "$CYGWIN" ]
then
 [ "$VSTATIC" -eq 0 ] && if NEEDED lisaem_private_src.rc lisaem_private.res; then VSTATIC=1; fi
 if [ "$VSTATIC" -gt 0 ]
 then
    echo win32 resources
    MINIVER="`echo $VERSION| cut -f1 -d'-' | sed 's/\./,/g'`,0"
    sed "s/_VERSION_/$VERSION/g" <lisaem_private_src.rc | sed "s/_MINIVER_/$MINIVER/g" >../resources/lisaem_private.rc
    cd ../resources
    # echo windres.exe --input-format=rc $RCINCS  -O coff lisaem_private.rc lisaem_private.res
    # some cygwin installs have their own windres which won't work with windows paths.  Force the use of
    # the wxDev-CPP one. :-)
    $WXDEV/bin/windres.exe --input-format=rc $RCINCS  -O coff lisaem_private.rc lisaem_private.res || exit 1
    cd ../lisa
 fi
 LIST="$LIST ..\\resources\\lisaem_private.res"
fi



rm -f lisaem lisaem.exe

# If we're on Darwin, we know the system libraries are there and we
# don't have to link statically against them. On Linux, link statically
# for the binary release so we don't have to worry about cross-distribution
# library version issues.
# Also, Apple's GCC doesn't support --static, so disable it there.
if [ -n "$DARWIN" ]
then
    SYSLIBS=
    GCCSTATIC=
else

    # only needed for wxX11 and we don't like those anymore
    ## [ -z "$CYGWIN" ] && \
    ## SYSLIBS="/usr/lib/libX*.a  /usr/lib/libcairo*.a /usr/lib/libpango*.a
    ##         /usr/lib/libfreetype.a /usr/lib/libexpat.a /usr/X11R6/lib/libICE.a
    ##         /usr/lib/librt.a /usr/lib/libXrender.a /usr/lib/libX11.a
    ##         /usr/lib/libfontconfig.a"

    GCCSTATIC=$STATIC
fi

#vars.c must be linked in before any C++ source code or else there will be linking conflicts!

cd ../wxui
echo
echo "* wxWidgets User Interface     (./wxui)"

# Compile C++

CFLAGS="$CFLAGS -DVERSION=\"${VERSION}\" "

for i in  lisaem_wx imagewriter-wx #lisaemframe lisawin
do
  if [ -z "$CYGWIN" ]; then LIST="$LIST ../wxui/${i}.o"
  else                      LIST="$LIST ..\\wxui\\${i}.o"
  fi

  if NEEDED ${i}.cpp ${i}.o
  then
     echo "  Compiling ${i}.cpp..."
     $CXX -W $WARNINGS $WITHDEBUG $WITHTRACE $WITHBLITS $CFLAGS -c ${i}.cpp -o ${i}.o || exit 1
  fi
done

CXXFLAGS="$CXXFLAGS -DVERSION=\"$VERSION\" "
for i in LisaConfig LisaConfigFrame
do
  if [ -z "$CYGWIN" ]; then LIST="$LIST ../wxui/${i}.o"
  else                      LIST="$LIST ..\\wxui\\${i}.o"
  fi

  DEPS=0;
  [ "$DEPS" -eq 0 ] && if NEEDED ${i}.cpp ${i}.o;   then DEPS=1; fi
  [ "$DEPS" -eq 0 ] && if NEEDED ${i}.h   ${i}.o;   then DEPS=1; fi

  if [ "$DEPS" -gt 0 ]
  then
     echo "  Compiling ${i}.cpp..."
     $CXX -W $WARNINGS $CXXFLAGS -c ${i}.cpp -o ${i}.o || exit 1
  fi
done


# hack compile until the big merge is done - this will be removed
# once merging is done and there will only be a single executable
# produced
# if [ -n "$WITHWXUI" ]
#then
# for i in LisaCanvas LisaEmApp LisaEmFrame
# do
#   if [ -z "$CYGWIN" ]; then WXLIST="$LIST ../wxui/${i}.o"
#   else                      WXLIST="$LIST ..\\wxui\\${i}.o"
#   fi
#
#   DEPS=0;
#   [ "$DEPS" -eq 0 ] && if NEEDED ${i}.cpp ${i}.o;   then DEPS=1; fi
#   [ "$DEPS" -eq 0 ] && if NEEDED ${i}.h   ${i}.cpp; then DEPS=1; fi
#
#   if [ "$DEPS" -gt 0 ]
#   then
#     echo Compiling ${i}.cpp...
#     $CXX -W $WARNINGS $CXXFLAGS -c ${i}.cpp -o ${i}.o || exit 1
#   fi
# done
#fi


for i in `echo $LIST`
do
 WXLIST="$WXLIST `echo $i|grep -v lisaem_wx`"
done

cd ../lisa

if [ -n "$DARWIN" ]
then
  echo "  Linking ./bin/LisaEm.app"
else
  echo "  Linking ./bin/lisaem"
fi

#echo $CXX $GCCSTATIC $WITHTRACE $WITHDEBUG -o ../bin/lisaem  $LIST ../generator/libgenerator.a ../cpu68k/lib68k.a $LINKOPTS $SYSLIBS
if [ -z "$WITHWXUI" ]
then
$CXX $GCCSTATIC $WITHTRACE $WITHDEBUG $LDFLAGS -o ../bin/lisaem  $LIST ../generator/libgenerator.a ../cpu68k/lib68k.a $LINKOPTS $SYSLIBS 2>&1  | head -20
echo
echo $CXX $GCCSTATIC $WITHTRACE $WITHDEBUG $LDFLAGS -o ../bin/lisaem  $LIST ../generator/libgenerator.a ../cpu68k/lib68k.a $LINKOPTS $SYSLIBS 2>&1  | head -20
fi

if [ -f ../bin/lisaem ]
then

cd ../bin
echo -n " "

# Report size and hashes ####

if [ -z "$DARWIN" ]
then
    SIZE="`du -sh lisaem 2>/dev/null`"
else
    SIZE="`du -sh LisaEm.app 2>/dev/null`"
fi


if [ -n "$DARWIN" ]
then

    mkdir -pm775 LisaEm.app/Contents/MacOS
    mkdir -pm775 LisaEm.app/Contents/Resources
    sed "s/_VERSION_/$VERSION/g" <../resources/Info.plist > LisaEm.app/Contents/Info.plist
    echo -n 'APPL????' > LisaEm.app/Contents/PkgInfo
    for i in LisaEm.icns floppy0.png floppy1.png floppy2.png \
             floppy3.png floppyN.png lisaface0.png           \
             lisaface1.png lisaface2.png lisaface3.png       \
             power_off.png power_on.png                      \
             floppy_eject.wav floppy_insert_sound.wav        \
             floppy_motor1.wav floppy_motor2.wav             \
             lisa_power_switch01.wav lisa_power_switch02.wav \
             poweroffclk.wav                                	
    do
	    RESCPYLIST="$RESCPYLIST ../resources/$i"
	done
	cp $RESCPYLIST LisaEm.app/Contents/Resources/   || exit 1

    [ -z "$WITHDEBUG" ] && strip ./lisaem
    chmod 755 lisaem
    mv lisaem LisaEm
    mv LisaEm LisaEm.app/Contents/MacOS/
    [ -n "$WITHDEBUG" ] && echo run >gdb-run && gdb ./LisaEm.app/Contents/MacOS/LisaEm
    #if we turned on profiling, process the results
    if [ `echo "$WITHDEBUG" | grep 'p' >/dev/null 2>/dev/null` ]
    then
      $GPROF LisaEm.app/Contents/MacOS/LisaEm/lisaem >lisaem-gprof-out
      echo lisaem-gprof-out created.
    fi

    if [ -n "$INSTALL" ]
    then
      cd ../bin/
      echo Installing LisaEm.app
      tar cf - ./LisaEm.app | (cd $PREFIX; tar xf -)
      mkdir -pm755 /usr/local/bin
      echo Installing lisafsh-tool and lisadiskinfo to /usr/local/bin
      chmod 755 lisafsh-tool lisadiskinfo
      cp lisafsh-tool lisadiskinfo /usr/local/bin
      echo Done Installing.
    fi
fi

# some older OS's don't support du -sh, so fall back to du -sk and convert to MB's
if [ -z "$SIZE" ]
then
    if [ -n "$DARWIN" ]
	then
        SIZE="`du -sk LisaEm.app 2>/dev/null | cut -f1`"
    else
   	    SIZE="`du -sk lisaem     2>/dev/null | cut -f1`"
    fi

    SIZE=$(( $SIZE / 1024))
    SIZE="${SIZE}M   lisaem"
fi
echo " $SIZE"

MD5BIN="`which md5 2>/dev/null`"
if [ -z "$MD5BIN" ]; then MD5BIN="`which md5sum 2>/dev/null`"; fi

if [ -n "$MD5BIN" ]
then
   if [ "$DARWIN" ]; then MD5="`$MD5BIN ./LisaEm.app/Contents/MacOS/LisaEm 2>/dev/null`"
   else                   MD5="`$MD5BIN ./lisaem                           2>/dev/null`"; fi
   [ -n "$MD5" ] && echo "  $MD5"         
fi                                        
                                          
MD5BIN="`which sha1 2>/dev/null`"
if [ -z "$MD5BIN" ]; then MD5BIN="`which sha1sum 2>/dev/null`"; fi

if [ -n "$MD5BIN" ]
then
   if [ "$DARWIN" ]; then MD5="`$MD5BIN ./LisaEm.app/Contents/MacOS/LisaEm 2>/dev/null`"
   else                   MD5="`$MD5BIN ./lisaem                           2>/dev/null`"; fi
   [ -n "$MD5" ] && echo "  $MD5"
fi

MD5BIN="`which sha256 2>/dev/null`"
if [ -z "$MD5BIN" ]; then MD5BIN="`which sha256sum 2>/dev/null`"; fi

if [ -n "$MD5BIN" ]
then
   if [ "$DARWIN" ]; then MD5="`$MD5BIN ./LisaEm.app/Contents/MacOS/LisaEm 2>/dev/null`"
   else                   MD5="`$MD5BIN ./lisaem                           2>/dev/null`"; fi
   [ -n "$MD5" ] && echo "  $MD5"
fi


echo
####


if [ -n "$DARWIN" ]; then echo "Done."; exit 0; fi  # end of OS X
	
if [ -z "$WITHDEBUG" ]
then

  echo "Freshly compiled `du -sh lisaem`"
  strip lisaem${EXT}
  echo "Stripped `du -sh lisaem`"

  # compress it if upx exists.
  if [ -z "$WITHOUTUPX"              ]; then
   if [ -n "`which upx 2>/dev/null`" ]
    then
      upx --best lisaem${EXT}
      echo "upxed `du -sh lisaem`"
   fi
  fi

  ## Install ###################################################
  if [ -n "$INSTALL" ]
  then


    if [ -n "$CYGWIN" ]
    then
         #PREFIX   ="/cygdrive/c/Program Files/Sunder.NET/LisaEm"
         #PREFIXLIB="/cygdrive/c/Program Files/Sunder.NET/LisaEm"
         echo "* Installing resources in     $PREFIXLIB/LisaEm"
         mkdir -p $PREFIX
         cp ../resources/*.wav $PREFIX
         echo "* Installing lisaem binary in $PREFIX/lisaem"
         cp ../bin/lisaem.exe $PREFIXLIB
         echo "  Done Installing."

      exit 0
    fi

    if [ -z "$CYGWIN" ]
    then

      #   PREFIX="/usr/local/bin"
      #   PREFIXLIB="/usr/local/share/"

      echo "* Installing resources in     $PREFIXLIB/lisaem"
      mkdir -pm755 $PREFIXLIB/LisaEm/ $PREFIX
      cp ../resources/*.wav ../resources/*.png $PREFIXLIB/lisaem/
      echo "* Installing lisaem binary in $PREFIX/lisaem"
      cp lisaem $PREFIX
      echo "  Done Installing."
      exit 0

    fi

  fi     # end of  INSTALL
  ##########################################################

else

 if [ -z "$CYGWIN" ]
 then
    cd ../bin 
    echo run >gdb-run
    gdb lisaem      -x gdb-run
 else
    cd ../bin 
    echo run >gdb-run
    gdb.exe lisaem.exe -x gdb-run
 fi


 if [ -n "`echo -- $WITHDEBUG | grep p`" ]
 then
   [ -n "$CYGWIN" ] && $GPROF lisaem.exe >lisaem-gprof-out.txt
   [ -z "$CYGWIN" ] && $GPROF lisaem     >lisaem-gprof-out.txt
 fi

fi


fi
