# Snow Crash

> 🇫🇷 [Version française](README.fr.md) · 📖 [Glossary](GLOSSARY.md)

Introduction to Linux security from the 42 curriculum. You are given a VM (the `SnowCrash` ISO) and start as `level00`. Each level contains a weakness that lets you become `flagXX`, run `getflag`, and obtain the token that is the password of the next `levelXX` user. There are **15 levels** (00 to 14).

> ⚠️ **Spoiler warning:** each `levelXX/resources/levelXX.md` write-up contains the token and the full solution.

## Setup

```bash
./vm.sh   # downloads the ISO, creates and configures the VM (SSH on port 4242)
```

Then connect to a level (the exact command for each is in `levelXX/resources/connect.md`):

```bash
ssh -p 4242 levelXX@<vm-ip>
```

## Repository layout

```
levelXX/
├── flag          # token for the next level
└── resources/
    ├── levelXX.md    # write-up
    └── connect.md    # connection details
```

## Levels

| Level | Vulnerability | Technique |
|-------|---------------|-----------|
| 00 | Weak encryption | Find a file owned by `flag00` with `find`; ROT cipher broken with CyberChef (ROT13 brute force) |
| 01 | Password hash in `/etc/passwd` | Crack the legacy DES hash with John the Ripper |
| 02 | Cleartext credentials in a network capture | Read a `.pcap` (Wireshark / `xxd`) and rebuild the password, handling backspace characters |
| 03 | SUID binary calling a command without absolute path | `PATH` hijacking with a fake `echo` in `/tmp` |
| 04 | Command injection in a Perl CGI script | Inject a shell command through the `x` parameter (backticks) |
| 05 | Writable directory executed by a cron job | Drop a script in `/opt/openarenaserver/`, executed by `flag05` every 2 minutes |
| 06 | `preg_replace` with the `/e` modifier (PHP) | Code execution via `[x ${`getflag`}]` |
| 07 | SUID binary trusting an environment variable | Inject a command through `LOGNAME` (found with `ltrace`) |
| 08 | Filename-based access check | Bypass the `token` check with a symbolic link |
| 09 | Weak obfuscation algorithm | Reverse the "add index to each byte" algorithm to decode the `token` file |
| 10 | Race condition (TOCTOU) | Swap a symlink between `access()` and `open()` while a listener on port 6969 receives the file |
| 11 | Command injection in a Lua server | `io.popen("echo "..pass.." \| sha1sum")` exploited via netcat on port 5151 |
| 12 | Command injection in a Perl CGI script (port 4646) | Bypass the uppercase conversion and space filtering with a script and shell globbing |
| 13 | UID check in a SUID binary | Spoof the return value of `getuid()` (`EAX` register) in GDB |
| 14 | Anti-debug protections in `getflag` | Bypass `ptrace` check and UID verification in GDB to get the `flag14` token |

## Tools used

`find`, `strings`, `ltrace`, `gdb`, `scp`, `nc` (netcat), `curl`, John the Ripper, Wireshark, CyberChef.

## Key takeaways

- Always use absolute paths and sanitise environment variables in privileged programs.
- Never build shell commands by concatenating user input.
- Do not rely on obscurity or weak ciphers to protect secrets.
- Check permissions on files and directories that privileged jobs read or execute.
- Avoid check-then-use patterns on the filesystem (`access()` then `open()`).
