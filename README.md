# neptune

The Direct3D path of Voile's Linux engine ([voile-ldk](https://github.com/Zagrios/voile-ldk)): UTM's Neptune, a
D3D11/DXGI/D3D12 driver for Windows guests that replays every call on the host, adapted to run in Wine for Linux on
macOS. Private.

| Folder | What it is | Upstream |
|---|---|---|
| `mesa/` | The guest driver (`src/virtio/neptune`): `d3d11.dll`, `dxgi.dll`, `d3d12.dll`, x86-64 PE, loaded in the game's process. It talks to the render server over the vtest socket and presents through voile-wine's `nptunix` and the wsd window server. | [osy/virtio-win-mesa](https://github.com/osy/virtio-win-mesa) `44d3259` |
| `virglrenderer/` | The render server for macOS arm64 (`virgl_test_server` and `virgl_render_server`): it replays the calls on DXMT, which renders with Metal. | [utmapp/virglrenderer](https://github.com/utmapp/virglrenderer) `482f9d8` |

## Branches

- `upstream` holds the two upstream trees exactly as imported, one commit each. Update it with a new import commit.
- `main` is `upstream` plus our changes, one commit each, rebased on `upstream` after an import.

## Building

```sh
LLVM_MINGW=<llvm-mingw folder> scripts/build-client.sh   # build/client/src/virtio/neptune/{d3d11,dxgi,d3d12}.dll
scripts/build-server.sh                                    # build/prefix/{bin,libexec,lib}
```

## Licenses

Both trees are MIT licensed (Neptune: Copyright Turing Software LLC; mesa and virglrenderer: their authors, see
`mesa/docs/license.rst` and `virglrenderer/COPYING`). Our changes are proprietary while this repository is private.
