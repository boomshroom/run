# `run`

For when you just wanna run something, but even bash feels like overkill.

Extremely minimal: no environment variable expansion; only adding arguments and variables.

Intended for shebang lines, especially with [`nitro`](https://git.vuxu.org/nitro/about/).
(Will unconditionally skip the first line.)

* Second line has the name or path of the binary to run
* Following lines containing an `=` are set as environment variables
* All remaining lines are passed as arguments.

No interpretation happens within a line beyond checking for `=`.

If even _this_ is too much, try [kaem-minimal](https://github.com/oriansj/stage0-posix-amd64/blob/master/kaem-minimal.hex0).
(Can run multiple commands, but not setting environment variables or `exec`, and also unconditionally prints each command to stdout.)
