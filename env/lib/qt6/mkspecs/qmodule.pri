QT_CPU_FEATURES.arm64 = neon crc32 crypto
QT.global_private.enabled_features = reduce_exports neon arm_crc32 arm_crypto alloca_h alloca system-zlib dbus gui network printsupport sql testlib widgets xml openssl dlopen relocatable largefile neon arm_crc32 arm_crypto
QT.global_private.disabled_features = use_bfd_linker use_gold_linker use_lld_linker use_mold_linker android-style-assets gc_binaries developer-build private_tests debug elf_private_full_version no_direct_extern_access x86intrin sse2 sse3 ssse3 sse4_1 sse4_2 avx f16c avx2 avx512f avx512er avx512cd avx512pf avx512dq avx512bw avx512vl avx512ifma avx512vbmi avx512vbmi2 aesni vaes rdrnd rdseed shani mips_dsp mips_dspr2 posix_fallocate alloca_malloc_h stack-protector-strong stdlib-libcpp dbus-linked libudev intelcet
CONFIG += largefile neon arm_crc32 arm_crypto
QT_COORD_TYPE = double
QT_BUILD_PARTS = libs tools

QMAKE_LIBS_ZLIB = -lz
QMAKE_LIBS_ZSTD = -lzstd.2 -lzstd
