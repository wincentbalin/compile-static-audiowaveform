#!/bin/sh
#
# Compile audiowaveform both for win32 and for win64 using MXE

SCRIPT_FILENAME=`readlink -f $0`
MINGW_PATCH=`dirname $SCRIPT_FILENAME`/audiowaveform-mingw.patch

# Set amount of MXE parallel compiling jobs
if [ "$JOBS" = "" ]
then
  JOBS=1
  export JOBS
fi

# Set MXE path
if [ "$MXE" = "" ]
then
  MXE=/opt/mxe
  export MXE
fi

# Check MXE path
if [ ! -d "$MXE" ]
then
  echo MXE not found in $MXE
  echo Please set the variable $MXE to the path of MXE!
  exit 1
fi

# Go to MXE directory and compile the dependencies
(cd "$MXE" && make MXE_TARGETS='x86_64-w64-mingw32.static i686-w64-mingw32.static' JOBS=$JOBS cc cmake gd libid3tag libmad libsndfile boost)

# Clone audiowaveform repository
if [ ! -d audiowaveform ]
then
  git clone https://github.com/bbc/audiowaveform.git
fi

# Check for directory with repository clone
if [ ! -d audiowaveform ]
then
  echo It seems we could not clone audiowaveform repository
  echo Exiting...
  exit 1
fi

# Prepare directories
cd audiowaveform
mkdir build-win32
mkdir build-win64

# Patch audiowaveform to be able to compile it with MinGW32
patch -t -p0 < "$MINGW_PATCH" || exit 1

# Compile for win32
cd build-win32 && \
cmake .. -DCMAKE_TOOLCHAIN_FILE=$MXE/usr/i686-w64-mingw32.static/share/cmake/mxe-conf.cmake -DENABLE_TESTS=0 -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -DBGDWIN32 -static-libgcc -static-libstdc++ -static" -DEXTRA_LIBS="-lFLAC -lvorbisenc -lvorbis -logg -lpng -lz" && \
make -j$JOBS && \
$MXE/usr/bin/i686-w64-mingw32.static-strip audiowaveform.exe && \
cd .. || exit 1

# Compile for win64
cd build-win64 && \
cmake .. -DCMAKE_TOOLCHAIN_FILE=$MXE/usr/x86_64-w64-mingw32.static/share/cmake/mxe-conf.cmake -DENABLE_TESTS=0 -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -DBGDWIN32 -static-libgcc -static-libstdc++ -static" -DEXTRA_LIBS="-lFLAC -lvorbisenc -lvorbis -logg -lpng -lz" && \
make -j$JOBS && \
$MXE/usr/bin/x86_64-w64-mingw32.static-strip audiowaveform.exe && \
cd .. || exit 1

# Collect results
cd ..
cp audiowaveform/build-win32/audiowaveform.exe audiowaveform-win32.exe
cp audiowaveform/build-win64/audiowaveform.exe audiowaveform-win64.exe
