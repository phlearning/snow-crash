# Glossary

🇫🇷 [Version française](GLOSSARY.fr.md) · [Back to README](README.md)

| Term | Definition |
|------|------------|
| **Anti-debug** | Techniques a program uses to detect and refuse analysis (e.g. `ptrace(PTRACE_TRACEME)`). |
| **CGI** | Common Gateway Interface: lets a web server run a script to answer a request. |
| **Command injection** | Getting a program to run attacker-chosen shell commands via unsanitised input. |
| **Cron job** | A scheduled task run periodically by the system. |
| **CyberChef** | Browser tool for encoding, decoding and crypto operations. |
| **EAX** | x86 register that holds a function's return value. |
| **`getflag`** | Binary that prints the token of the current `flagXX` user. |
| **GDB** | GNU debugger, used to inspect and alter a program at runtime. |
| **Globbing** | Shell wildcard expansion (`*`, `?`), useful to bypass character filters. |
| **John the Ripper** | Password cracking tool. |
| **`ltrace`** | Traces a program's library calls (e.g. `getenv`, `system`). |
| **`LD_PRELOAD`** | Environment variable to load a library first; ignored for SUID binaries. |
| **`PATH` hijacking** | Placing a fake executable in a directory searched first by `$PATH`. |
| **`ptrace`** | System call used by debuggers; also used by programs to detect them. |
| **Race condition** | A bug whose outcome depends on timing between concurrent operations. |
| **ROT13 / Caesar cipher** | Simple substitution cipher that shifts letters by a fixed amount. |
| **SUID** | Set User ID bit: the binary runs with the privileges of its owner. |
| **Symlink** | Symbolic link: a file that points to another path. |
| **`strings`** | Prints printable strings found in a binary. |
| **TOCTOU** | Time-Of-Check to Time-Of-Use: a race between a check and the use of a resource. |
| **Token** | Here, the value `getflag` returns, used as the next level's password. |
| **Wireshark / pcap** | Network analyser and its packet capture file format. |
