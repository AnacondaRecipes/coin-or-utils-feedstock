#!/usr/bin/env bash
set -e

# Always update config.guess / config.sub — required on Windows too
cp "$BUILD_PREFIX/share/gnuconfig/config.guess" ./CoinUtils/config.guess
cp "$BUILD_PREFIX/share/gnuconfig/config.sub"   ./CoinUtils/config.sub
cp "$BUILD_PREFIX/share/gnuconfig/config.guess" ./config.guess
cp "$BUILD_PREFIX/share/gnuconfig/config.sub"   ./config.sub

if [ -n "${LIBRARY_PREFIX+x}" ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
    BLAS_LIB=( --with-blas-lib='${LIBRARY_PREFIX}/lib/mkl_rt.lib' )
    LAPACK_LIB=( --with-lapack-lib='' )
    EXTRA_FLAGS=( --enable-msvc=MD )
else
    BLAS_LIB=( --with-blas-lib="$(pkg-config --libs openblas 2>/dev/null || echo '-L${PREFIX}/lib -lopenblas')" )
    LAPACK_LIB=( --with-lapack-lib="$(pkg-config --libs openblas 2>/dev/null || echo '-L${PREFIX}/lib -lopenblas')" )
    EXTRA_FLAGS=()
fi

./configure \
    --prefix="${USE_PREFIX}" \
    --exec-prefix="${USE_PREFIX}" \
    "${BLAS_LIB[@]}" \
    "${LAPACK_LIB[@]}" \
    "${EXTRA_FLAGS[@]}" || { cat CoinUtils/config.log; exit 1; }

make -j "${CPU_COUNT}"
make test
make install