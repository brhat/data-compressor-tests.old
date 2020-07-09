# data-compressor-tests
This repository contains automated tests for the data-compressor: https://github.com/CenterForSecureEnergyInformatics/data-compressor
The tests can be used manually, but are intended for a CI system (buildbot).
The proper envirionment for building and testing is chosen automatically.

## prerequisites
On Windows, you have to have installed:
- git (you need gitbash)
- Microsoft C++ Build Tools

On Linux, you need gcc for your platform.

The source files for the data-compressor and checkBitSize have to be next to the folder containing ths project.
Other locations can be specified via the variables checkBitSizePath and dataCompressorPath in the scripts.

## buildAndTest.sh

buildAndTest.sh <i386|x86_64|armhf|arm|win32|x64> <IO_SIZE_BITS>

First, the data-compressor is built for the platform specified via the first argument.
The second argument specifies IO_SIZE_BITS.

After compilation, testdata (contained in the data-compressor repository) is compressend and decompressed with the following methods:
- dega
- lzmh
- copy

The resulting data is compared to the input via diff.
If input and output differs for some tests, the script will return an error.

## checkBits.sh

checkBits.sh <i386|x86_64|armhf|arm|win32|x64>

This script compiles and runs the program checkBitSize on the specified platform.
