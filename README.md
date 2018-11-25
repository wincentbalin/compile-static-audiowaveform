# audiowaveform compilation for Windows using MinGW
Compile [audiowaveform](https://github.com/bbc/audiowaveform) to static Windows binaries using MinGW in Docker.

## Building
Just run

```bash
./compile_audiowaveform.sh
```

in _Docker Quickstart Terminal_, if you are in Windows, or in any terminal with _Docker_ installed, if in Linux.

After a while you will have two files, `audiowaveform-mingw32.zip` and `audiowaveform-mingw64.zip`, with 32-bit and 64-bit versions
respectively, in the same directory. These two archives contain all intermittently compiled libraries and binaries.
The **audiowaveform** binary resides in the file `bin/audiowaveform.exe` in any of the archives.

If you prefer using [MXE](https://mxe.cc/) to cross-compile Windows binaries, you may use the script `compile_audiowaveform_mxe.sh`.

