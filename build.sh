#!/bin/bash

CC=emcc
CCFLAGS="-O3 -ffast-math -Iinclude"

BIGINT_SRCDIR=zxing-cpp/core/src/bigint
BIGINT_INCLUDES="-I$BIGINT_SRCDIR"
BIGINT_SRCS="BigInteger.cc BigIntegerAlgorithms.cc BigUnsigned.cc BigUnsignedInABase.cc BigIntegerUtils.cc"
BIGINT_OUTDIR=build/zxing/bigint

ZXING_BASEDIR=zxing-cpp/core/src/zxing
ZXING_FILES=$(find $ZXING_BASEDIR -name "*.cpp")
ZXING_SRCFILES=""
ZXING_BCFILES=""
ZXING_OUTDIRS=""
ZXING_INCLUDES="-I$ZXING_BASEDIR/.."
ZXING_OUTDIR=build/zxing

for file in $ZXING_FILES; do
  ZXING_SRCFILES="$ZXING_SRCFILES $file"
  temp=${file//zxing-cpp\/core\/src\/zxing/"$ZXING_OUTDIR"}
  temp=${temp%\/*}
  if [[ $ZXING_OUTDIRS != *$temp* ]]
  then
    ZXING_OUTDIRS="$ZXING_OUTDIRS $temp"
  fi
done

WRAPPER_SRCDIR=src/emscripten
WRAPPER_INCLUDES="$ZXING_INCLUDES"
WRAPPER_SRCS="wrapper.cpp ImageDataSource.cpp"
WRAPPER_OUTDIR=build/wrapper

COMPILE_PREJS=src/emscripten/pre.js
COMPILE_POSTJS=src/emscripten/post.js
COMPILE_TARGET=zxing-module.js
COMPILE_OUTDIR=src
COMPILE_FLAGS="-s EXPORTED_FUNCTIONS=@exported_functions.json"
COMPILE_FLAGS="$COMPILE_FLAGS --pre-js $COMPILE_PREJS --post-js $COMPILE_POSTJS"
COMPILE_FLAGS="--llvm-lto 1 --memory-init-file 0 -Oz -s DISABLE_EXCEPTION_CATCHING=0 -s NO_FILESYSTEM=1 $COMPILE_FLAGS"

set -e

if [[ ! -d "${BIGINT_OUTDIR}" ]] ; then
  mkdir -p $BIGINT_OUTDIR

  echo "== Building BigInt =="

  for srcfile in $BIGINT_SRCS; do
    buildcmd="$CC $CCFLAGS $BIGINT_INCLUDES $BIGINT_SRCDIR/$srcfile -o $BIGINT_OUTDIR/${srcfile%.*}.bc"
    echo $buildcmd
    $buildcmd
  done

else
  echo "!! Skipping bigint (remove ${BIGINT_OUTDIR} to rebuild) !!"
fi

if [[ ! -d "${ZXING_OUTDIR}/oned" ]] ; then
  mkdir -p $ZXING_OUTDIRS
  BUILD_ZXING=true
  echo "== Building zxing =="
else
  echo "!! Skipping zxing (remove ${ZXING_OUTDIR} to rebuild) !!"
fi

for srcfile in $ZXING_SRCFILES; do
  temp=${srcfile/$ZXING_BASEDIR/$ZXING_OUTDIR}
  outfile="${temp%.*}.bc"
  ZXING_BCFILES="$ZXING_BCFILES $outfile"
  buildcmd="$CC $CCFLAGS $ZXING_INCLUDES $srcfile -o $outfile"
  if [[ "$BUILD_ZXING" = true ]] ; then
    echo $buildcmd
    $buildcmd
  fi
done


if [[ ! -d "${WRAPPER_OUTDIR}" ]] ; then
  mkdir -p $WRAPPER_OUTDIR
fi

echo "== Building wrapper =="

for srcfile in $WRAPPER_SRCS; do
  buildcmd="$CC $CCFLAGS $WRAPPER_INCLUDES $WRAPPER_SRCDIR/$srcfile -o $WRAPPER_OUTDIR/${srcfile%.*}.bc"
  $buildcmd
done

mkdir -p $COMPILE_OUTDIR
WRAPPER_BCS="$WRAPPER_OUTDIR/*.bc"
BIGINT_BCS="$BIGINT_OUTDIR/*.bc"

echo "== Compiling target =="

buildcmd="$CC $COMPILE_FLAGS $BIGINT_BCS $ZXING_BCFILES $WRAPPER_BCS -o $COMPILE_OUTDIR/$COMPILE_TARGET"
$buildcmd

echo "== DONE =="
