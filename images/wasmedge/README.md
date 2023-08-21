<!--monopod:start-->
# wasmedge
| | |
| - | - |
| **Status** | stable |
| **OCI Reference** | `cgr.dev/chainguard/wasmedge` |


* [View Image in Chainguard Academy](https://edu.chainguard.dev/chainguard/chainguard-images/reference/wasmedge/overview/)
* [View Image Catalog](https://console.enforce.dev/images/catalog) for a full list of available tags.
*[Contact Chainguard](https://www.chainguard.dev/chainguard-images) for enterprise support, SLAs, and access to older tags.*

---
<!--monopod:end-->

This image contains the CLI for the WasmEdge tool.
WasmEdge is an open-source platform for building, deploying and managing WebAssembly applications.
This image ca be used to build and run Wasm apps.

## Get It!

The image is available on `cgr.dev`:

```
docker pull cgr.dev/chainguard/wasmedge:latest
```

## Use It!

The image can be run directly and sets the wasmedge cli as the entrypoint:

```
docker run cgr.dev/chainguard/wasmedge:latest
USAGE
        /usr/bin/wasmedge [SUBCOMMANDS] [OPTIONS] [--] WASM_OR_SO [ARG ...]

SUBCOMMANDS
        compile
                Wasmedge compiler subcommand
        run
                Wasmedge runtime tool subcommand

OPTIONS

-h|--help
                Show this help messages

-v|--version
                Show version information

--reactor
                Enable reactor mode. Reactor mode calls `_initialize` if exported.

--dir
                Binding directories into WASI virtual filesystem. Each directory can be
                specified as --dir `host_path`. You can also map a guest directory to a host
                directory by --dir `guest_path:host_path`, where `guest_path` specifies the
                path that will correspond to `host_path` for calls like `fopen` in the
                guest.The default permission is `readwrite`, however, you can use --dir
                `guest_path:host_path:readonly` to make the mapping directory become a read
                only mode.

--env
                Environ variables. Each variable can be specified as --env `NAME=VALUE`.
```

This image also contains the `wasmedgec` compiler tool which can be used to compile Wasm
modules into native machine code.

```shell
docker run --entrypoint=wasmedgec -v $(pwd):/app cgr.dev/chainguard/wasmedge:latest /app/images/wasmedge/tests/wasmtest /app/images/wasmedge/tests/wasmedge_aot
[2023-08-21 11:39:52.206] [info] compile start
[2023-08-21 11:39:52.321] [info] verify start
[2023-08-21 11:39:52.413] [info] optimize start
[2023-08-21 11:39:58.906] [info] codegen start
[2023-08-21 11:40:04.509] [info] output start
[2023-08-21 11:40:04.668] [info] compile done
```

This can then be run again with `wasmedge`:

```shell
docker run -v $(pwd):/app cgr.dev/chainguard/wasmedge:latest /app/images/wasmedge/tests/wasmtest_aot
Hello, World!
```
