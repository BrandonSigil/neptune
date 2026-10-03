#!/bin/bash
# Builds the Neptune guest driver (d3d11.dll, dxgi.dll, d3d12.dll, x86-64 PE) with llvm-mingw into build/client.
# LLVM_MINGW: the llvm-mingw folder (Voile downloads it, see its sources.json). Needs meson and ninja.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
: "${LLVM_MINGW:?set LLVM_MINGW to the llvm-mingw folder}"
B="$HERE/build/client"
mkdir -p "$B"
cat > "$B/cross-mingw.txt" <<CROSS
[binaries]
c = '$LLVM_MINGW/bin/x86_64-w64-mingw32-clang'
cpp = '$LLVM_MINGW/bin/x86_64-w64-mingw32-clang++'
ar = '$LLVM_MINGW/bin/x86_64-w64-mingw32-ar'
strip = '$LLVM_MINGW/bin/x86_64-w64-mingw32-strip'
windres = '$LLVM_MINGW/bin/x86_64-w64-mingw32-windres'
pkg-config = 'false'

[host_machine]
system = 'windows'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'

[properties]
needs_exe_wrapper = true
CROSS
[ -f "$B/build.ninja" ] || meson setup "$B" "$HERE/mesa" --cross-file="$B/cross-mingw.txt" \
  -Dbuildtype=release -Db_lto=false -Dexpat=disabled -Dgallium-drivers= -Dglx=disabled -Dneptune=true \
  -Dopengl=false -Dplatforms= -Dvulkan-drivers= -Dwrap_mode=nodownload -Dxmlconfig=disabled -Dzlib=disabled \
  -Dzstd=disabled -Dnpt_wsi=wsd
ninja -j "${JOBS:-4}" -C "$B" src/virtio/neptune/d3d11.dll src/virtio/neptune/dxgi.dll src/virtio/neptune/d3d12.dll
ls -l "$B"/src/virtio/neptune/*.dll
