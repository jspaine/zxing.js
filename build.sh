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

WRAPPER_SRCDIR=src
WRAPPER_INCLUDES="$ZXING_INCLUDES"
WRAPPER_SRCS="wrapper.cpp ImageDataSource.cpp"
WRAPPER_OUTDIR=build/wrapper

COMPILE_PREJS=src/pre.js
COMPILE_POSTJS=src/post.js
COMPILE_TARGET=barcodereader.js
COMPILE_TARGET_OPT=barcodereader.min.js
COMPILE_OUTDIR=dist
COMPILE_FLAGS="-s DISABLE_EXCEPTION_CATCHING=0 -s ALLOW_MEMORY_GROWTH=1 -s ASM_JS=1 -s EXPORTED_FUNCTIONS=@exported_functions.json"
COMPILE_FLAGS="$COMPILE_FLAGS --pre-js $COMPILE_PREJS --post-js $COMPILE_POSTJS"
COMPILE_FLAGS_OPT="-O3 $COMPILE_FLAGS"
COMPILE_FLAGS="-O1 $COMPILE_FLAGS"

set -e

mkdir -p $BIGINT_OUTDIR

echo "== Building BigInt lib =="

for srcfile in $BIGINT_SRCS; do
  buildcmd="$CC $CCFLAGS $BIGINT_INCLUDES $BIGINT_SRCDIR/$srcfile -o $BIGINT_OUTDIR/${srcfile%.*}.bc"
  echo $buildcmd
  $buildcmd
done

mkdir -p $ZXING_OUTDIRS

echo "== Building zxing =="

for srcfile in $ZXING_SRCFILES; do
  temp=${srcfile/$ZXING_BASEDIR/$ZXING_OUTDIR}
  outfile="${temp%.*}.bc"
  ZXING_BCFILES="$ZXING_BCFILES $outfile"
  buildcmd="$CC $CCFLAGS $ZXING_INCLUDES $srcfile -o $outfile"  
  echo $buildcmd
  $buildcmd
done

mkdir -p $WRAPPER_OUTDIR

echo "== Building wrapper =="

for srcfile in $WRAPPER_SRCS; do
  buildcmd="$CC $CCFLAGS $WRAPPER_INCLUDES $WRAPPER_SRCDIR/$srcfile -o $WRAPPER_OUTDIR/${srcfile%.*}.bc"
  echo $buildcmd
  $buildcmd
done

mkdir -p $COMPILE_OUTDIR
WRAPPER_BCS="$WRAPPER_OUTDIR/*.bc"
BIGINT_BCS="$BIGINT_OUTDIR/*.bc"

echo "== Compiling target =="

buildcmd="$CC $COMPILE_FLAGS $BIGINT_BCS $ZXING_BCFILES $WRAPPER_BCS -o $COMPILE_OUTDIR/$COMPILE_TARGET"
echo $buildcmd
$buildcmd

echo "== Compiling target (minified) =="

buildcmd="$CC $COMPILE_FLAGS_OPT $BIGINT_BCS $ZXING_BCFILES $WRAPPER_BCS -o $COMPILE_OUTDIR/$COMPILE_TARGET_OPT"
echo $buildcmd
$buildcmd

echo "== DONE =="
