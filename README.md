<p align="center">
  <img src="https://sncfoundation.github.io/logos/sheetassembly.svg" width="96" alt="SheetAssembly logo">
</p>

<h1 align="center">SheetAssembly</h1>

<p align="center"><b>Schedule WASI/WASM workloads from a Sheet</b><br>
A <a href="https://sncfoundation.github.io">Sheet-Native Computing Foundation</a> project &#183; analog of <b>runwasi</b></p>

---

**Status:** 💾 Autosaving &#183; promoted from Unsaved Draft. Working code, released as [v0.1.0](https://github.com/sncfoundation/sheetassembly/releases/tag/v0.1.0), and the [tracking issue #24](https://github.com/sncfoundation/sheeternetes/issues/24) is closed. Google keeps saving it.

## About

Schedule WASI/WASM workloads from a Sheet Part of the spreadsheet-native stack — the Sheet stays the source of truth, and it reconciles.

Instead of a pod being a Docker container, a pod is a **WASM module** run via
[`wasmtime`](https://wasmtime.dev). A wasm-aware kubelet shim keys on
`"runtime":"wasm"` in the manifest and runs `wasmtime run <module>` per replica,
so the same bin-packing scheduler that places containers can place WASI modules.

## Usage

The `sheetassembly` CLI is a single Bash script. It needs `bash`, plus
[`wasmtime`](https://wasmtime.dev) to run modules and
[`wat2wasm`](https://github.com/WebAssembly/wabt) (from wabt) to build them.

```bash
# Install the runtime tools (macOS / Homebrew shown; see hints for other OSes)
brew install wasmtime wabt
```

### Build and run the sample module

`hello.wat` is a valid WASI module that writes `it reconciles` to stdout via
`fd_write`. Compile it and run it:

```bash
wat2wasm hello.wat -o hello.wasm && sheetassembly run hello.wasm
# -> it reconciles
```

Or use the wrapper, which just shells out to `wat2wasm`:

```bash
sheetassembly build hello.wat        # produces hello.wasm
sheetassembly run   hello.wasm       # -> it reconciles
```

Arguments after the module path are passed through to the guest:

```bash
sheetassembly run mymodule.wasm --flag value
```

If `wasmtime` or `wat2wasm` is missing, the CLI prints a clear install hint and
exits non-zero.

### Schedule a workload

`schedule` emits a Sheeternetes-style deployment manifest with
`"runtime":"wasm"` and the module path. Feed it to the Sheet the same way you
would any other manifest (e.g. `skctl apply`); a wasm-aware kubelet shim runs
each replica with `wasmtime` instead of Docker.

```bash
sheetassembly schedule hello.wasm --name reconciler --replicas 3
```

```json
{
  "_note": "SheetAssembly WASI workload. runtime=wasm -> a wasm-aware kubelet shim runs `wasmtime run <module>` per replica instead of docker.",
  "deployments": [
    {
      "name": "reconciler",
      "runtime": "wasm",
      "module": "hello.wasm",
      "image": "",
      "replicas": 3,
      "cpu_req": 50,
      "mem_req": 16,
      "command": ""
    }
  ]
}
```

### Commands

| Command | What it does |
| --- | --- |
| `sheetassembly run <module.wasm> [args...]` | Run a WASI module via `wasmtime`. |
| `sheetassembly build <module.wat> [-o out.wasm]` | Compile `.wat` → `.wasm` via `wat2wasm`. |
| `sheetassembly schedule <module.wasm> --name <n> --replicas <r>` | Emit a `runtime:wasm` manifest. |

## Get involved

- 📋 Tracking issue &amp; design: [sncfoundation/sheeternetes#24](https://github.com/sncfoundation/sheeternetes/issues/24) (closed)
- 🗺️ [SNCF Landscape](https://sncfoundation.github.io/landscape.html)
- 🧩 [All projects](https://sncfoundation.github.io/projects.html)
- ⚖️ [Governance &amp; how to contribute](https://github.com/sncfoundation/governance)
- 🎓 [Get certified (CSFE)](https://sncfoundation.github.io/certification.html)

## Status legend

Everything starts as an **Unsaved Draft**. It reconciles up the tiers from there — see the
[maturity model](https://sncfoundation.github.io/foundation.html#maturity).

---

<sub>Licensed under Apache-2.0. The SNCF does not recommend running production on a spreadsheet. If you do, please film it.</sub>
