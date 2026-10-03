#!/bin/bash
# Builds the Neptune render server for macOS arm64 (virgl_test_server, virgl_render_server, libvirglrenderer) into
# build/prefix, with libepoxy 1.5.10 (no GL platforms) built first. Needs meson, ninja and Python with PyYAML and Mako.
# The server loads DXMT at run time: NPT_BACKEND=dxmt NPT_D3D11_LIBRARY_PATH=... NPT_DXGI_LIBRARY_PATH=...
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
PFX="$HERE/build/prefix"
DL="$HERE/build/dl"
EPOXY_URL=https://github.com/anholt/libepoxy/releases/download/1.5.10/libepoxy-1.5.10.tar.xz
EPOXY_SHA256=072cda4b59dd098bba8c2363a6247299db1fa89411dc221c8b81b8ee8192e623
mkdir -p "$DL"
if [ ! -f "$PFX/lib/libepoxy.0.dylib" ]; then
  [ -f "$DL/libepoxy-1.5.10.tar.xz" ] || curl -fL -o "$DL/libepoxy-1.5.10.tar.xz" "$EPOXY_URL"
  echo "$EPOXY_SHA256  $DL/libepoxy-1.5.10.tar.xz" | shasum -a 256 -c -
  tar -xf "$DL/libepoxy-1.5.10.tar.xz" -C "$DL"
  meson setup "$HERE/build/epoxy" "$DL/libepoxy-1.5.10" --prefix="$PFX" -Dtests=false -Dglx=no -Degl=no -Dx11=false \
    --buildtype=release
  ninja -j "${JOBS:-4}" -C "$HERE/build/epoxy" && meson install -C "$HERE/build/epoxy"
fi
[ -f "$HERE/build/server/build.ninja" ] || meson setup "$HERE/build/server" "$HERE/virglrenderer" --prefix="$PFX" \
  --pkg-config-path="$PFX/lib/pkgconfig" -Dneptune=true -Dvenus=false -Dvtest=true -Drender-server-mode=process \
  -Drender-server-worker=process -Dtests=false -Dcheck-gl-errors=false --buildtype=release
ninja -j "${JOBS:-4}" -C "$HERE/build/server"
meson install -C "$HERE/build/server" >/dev/null
ls -l "$PFX/bin/virgl_test_server" "$PFX/libexec/virgl_render_server" "$PFX/lib/libvirglrenderer.1.dylib"
