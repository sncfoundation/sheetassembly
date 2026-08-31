(module
  ;; SheetAssembly sample WASI module.
  ;; Writes "it reconciles\n" to stdout (fd 1) via wasi_snapshot_preview1.fd_write.
  ;;
  ;;   wat2wasm hello.wat -o hello.wasm
  ;;   sheetassembly run hello.wasm      # -> it reconciles

  (import "wasi_snapshot_preview1" "fd_write"
    (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory 1)
  (export "memory" (memory 0))

  ;; The message lives at offset 8. It is 14 bytes: "it reconciles\n".
  (data (i32.const 8) "it reconciles\n")

  (func (export "_start")
    ;; Build a single iovec at offset 0:
    ;;   [0..4)  = pointer to the string data (8)
    ;;   [4..8)  = length of the string data (14)
    (i32.store (i32.const 0) (i32.const 8))
    (i32.store (i32.const 4) (i32.const 14))

    ;; fd_write(fd=1 stdout, iovs=0, iovs_len=1, nwritten=20)
    (call $fd_write
      (i32.const 1)
      (i32.const 0)
      (i32.const 1)
      (i32.const 20))
    drop))
