# HollowOS

A hobby operating system written from scratch in C++ and x86 assembly. It boots as a 32-bit Multiboot kernel, draws a graphical desktop, talks to the internet through its own network stack (including HTTPS), stores files on a disk, and can run simple Linux i386 programs.

> **Project status: alpha, educational.**
> The code compiles and links cleanly, and its core libraries (cryptography, TLS, HTTP client, HTML converter, filesystem) are covered by host-side tests. **The kernel itself has not yet been booted in QEMU**, so expect first-boot bugs. See [Testing](#testing) and [Known limitations](#known-limitations).

## Features

| Area | What is included |
|------|------------------|
| **Desktop** | 1024x768x32 framebuffer, draggable windows, taskbar with pinned apps, network/disk indicators and clock, start menu, desktop icons, absolute mouse via VMware backdoor |
| **DuckDuckGo** | The system's official app. Searches and browses over HTTPS directly from inside the OS (no external proxy), with clickable results, history, and back/forward/reload |
| **Files** | HFS filesystem (directory tree, 3 MB of data) persisted to an ATA disk, plus a graphical file manager with text preview |
| **Terminal** | Shell with file commands, output redirection (`>`, `>>`), network tools and Linux program launching |
| **Networking** | Intel e1000 driver, ARP, IPv4, ICMP, UDP, DHCP, DNS, TCP, TLS 1.2 client, HTTP/1.1 client |
| **Linux compatibility** | Ring-3 user mode, ~120 Linux i386 syscalls, ELF loader for static, PIE and dynamically linked executables |

## Quick start

### Requirements

- `g++` with 32-bit code generation (`-m32`), GNU `ld` and `make`
- `nasm`
- `qemu-system-i386`
- Python 3 with the `cryptography` package (only for `make test`)

### Build and run

```sh
make          # build hollowos.bin
make run      # build, create hollow.img (8 MB) if missing, and start QEMU
make test     # host-side tests (crypto, filesystem, HTML)
make clean    # remove build artifacts (hollow.img is kept)
```

`make run` starts QEMU with 256 MB of RAM, the standard VGA adapter, an e1000 NIC using QEMU's user-mode networking (DHCP and DNS provided by QEMU), and `hollow.img` as an IDE disk. A blank disk is formatted automatically on first boot. A disk that already contains non-HFS data is never touched; the OS falls back to RAM-only and warns you.

## Using HollowOS

The desktop opens with DuckDuckGo and a terminal. Type a search or an address in DuckDuckGo and press Enter; click blue lines to follow links. `Esc` cancels a running network operation, `Ctrl+C` stops a running Linux program.

### Terminal commands

```
Files      ls [-l] [dir]  pwd  cd <dir>  cat <file>  mkdir <dir>  touch <file>
           cp <a> <b>  mv <a> <b>  rm [-r] <path>  df  sync  format sim
Redirect   <command> > file     <command> >> file
Internet   ddg <query>  curl <url>  wget [-O name] <url>  net  ping <host>
Programs   apps  open <app>  run <program> [args]  ./program
System     clear  echo  date  time  ver  neofetch  exit  reboot  shutdown
```

Files are written to the disk automatically a few seconds after changes; `sync` writes them immediately.

### Running Linux programs

Place an i386 ELF binary in the filesystem (for example with `wget`) and run it by path or with `run`. Statically linked programs work out of the box. Dynamically linked programs additionally need their interpreter and libraries under `/lib` and `/usr/lib`. A sample program is installed at `/bin/hello`.

## Architecture

```
boot.asm      Multiboot entry, stack setup
kernel.cpp    Video, windowing, input, desktop, apps (DuckDuckGo, Files, Terminal), shell
userland.cpp  GDT/IDT/TSS, user mode, int 0x80 syscall layer, ELF loader
net.cpp       e1000 driver, ARP/IP/ICMP/UDP/DHCP/DNS/TCP
tls.cpp       TLS 1.2 client (ECDHE x25519, AES-128-GCM)
crypto.cpp    SHA-256, HMAC, TLS PRF, AES-128-GCM, X25519, random generator
web.cpp       URL handling and HTTP/1.1 client (GET/POST, redirects, chunked)
html.cpp      HTML-to-text conversion with links; DuckDuckGo results parser
vfs.cpp       HFS filesystem (inode table + FAT of 4 KB blocks)
disk.cpp      ATA PIO driver (LBA28)
tests/        Host-side tests and local test servers
```

**Memory map** (identity-mapped, no paging; QEMU needs `-m 256`)

| Range | Use |
|-------|-----|
| 1 MB - ~11 MB | Kernel image and BSS (checked at link time to stay below 16 MB) |
| 16 MB - 176 MB | Main program (ET_EXEC, below 160 MB; PIE loaded at `0x08048000`) followed by the heap (`brk`) |
| 176 MB - 184 MB | Dynamic linker (`PT_INTERP`) |
| 184 MB - 222 MB | `mmap` region |
| up to 224 MB | User stack |

**Filesystem (HFS).** Up to 255 files and directories with names of at most 27 characters, 4 KB blocks, 3 MB of data. Everything lives in RAM and is flushed to the ATA disk (dirty blocks plus metadata); the disk is loaded at boot. There is no journaling, so a power loss during a write can corrupt the image.

## Testing

`make test` and the files under `tests/` verify, on the host:

- SHA-256, HMAC, TLS PRF, AES-GCM and X25519 against Python's `hashlib` and `cryptography`
- The TLS client against an OpenSSL-based TLS 1.2 server (RSA and ECDSA certificates), including a 1.5 MB transfer with checksum verification (`tests/tls_server.py`, `tests/tls_shim.cpp`)
- The HTTP/HTTPS client: GET, POST, redirects, chunked and read-until-close bodies (`tests/web_server.py`, `tests/web_test.cpp`)
- The HTML converter and URL resolver
- The filesystem, including persisting to and remounting from a simulated disk

Not covered: booting the kernel, hardware drivers (e1000, ATA, VBE), the GUI, and the Linux syscall layer and ELF loader.

## Security notes

- **TLS does not validate server certificates.** Traffic is encrypted, which protects against passive eavesdropping, but an active man-in-the-middle can impersonate any site. Do not enter passwords or other secrets.
- Only x25519 key exchange is implemented; servers that require P-256 will fail with an explicit error.
- Entropy comes from input timing and the CPU timestamp counter and is weak under emulation.
- There is no memory protection between the kernel and user programs (no paging).

## Known limitations

- Single process: **no `fork`, `execve`, `pipe` or threads**. Shells and pipelines do not run; programs must be self-contained.
- One TCP connection and one UDP socket at a time; no listening sockets.
- No `/proc` or `/sys`; `select` is not implemented (`poll` is).
- The browser renders text and links only: no CSS, JavaScript, images or forms.
- The filesystem is limited to 3 MB and 255 entries.

See [ROADMAP.md](ROADMAP.md) for the planned work: certificate validation, paging, multitasking with `fork`/`exec`, larger storage and more.

## License

Educational project. Use, modify and learn from it freely.
