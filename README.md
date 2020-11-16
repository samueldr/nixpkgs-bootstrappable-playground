Bootstrappable playground
=========================

*Bootstrappable as in https://bootstrappable.org/*

* * *

This is totally non-commital, done for exploration.

This currently builds Mes and related tools at version 0.21.

The state is that the

Usage
-----

Maybe don't.

But, you can run a small test sample using

```
 $ env -i nix-build -A tests
```

This will also run the compiler test suites as they are built.

```
 $ env -i nix-build -A tinycc-boot
...
 $ nix path-info -rsSh ./result
/nix/store/bpqmn8w0ikhw6mhihq3wfvxd9jk97qds-mescc-tools-1.0.1+2020-11-08-i686-unknown-linux-musl        186.0K  186.0K
/nix/store/j2p3wzzk0rs5qj6djbjhw39gw8pgvbp0-mes-0.21                                                      5.2M    5.4M
/nix/store/vqzxvbdb8f0944kpf3vms5pjihzsbw5x-tinycc-boot                                                   1.0M    6.4M
```
