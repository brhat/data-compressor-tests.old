#!/usr/bin/env bash

# automated build and test script for the datacompressor.
# the functions containing the actual tests can be found in separate scripts in the same directory
# the emulator function is used by the testfunctions and also contained in another file.

set -euo pipefail

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$workdir/emulator.sh"
source "$workdir/test_dega.sh"
source "$workdir/test_lzmh.sh"
source "$workdir/test_copy.sh"

dataCompressorPath="../data-compressor"

is_numeric_regex='^[0-9]+$'

linux_dccli_sep="\#"
windows_dccli_sep="\#"

linux_dccli_build_dir="$dataCompressorPath/DataCompressor/build/gcc/"
linux_dccli_command="$dataCompressorPath/DataCompressor/build/gcc/DCCLI"

testdata_input="$dataCompressorPath/DataCompressor/DCCLI/testdata/input.txt"
testdata_output="$dataCompressorPath/DataCompressor/DCCLI/testdata/output.txt"

windows_compiler="/c/Program\ Files\ \(x86\)/MSBuild/12.0/Bin/MSBuild.exe"
windows_project_file="$dataCompressorPath/DataCompressor/build/MSVC/DataCompressor.sln"
win32_dccli_command="$dataCompressorPath/DataCompressor/build/MSVC/Release/DCCLI.exe"
win_x64_dccli_command="$dataCompressorPath/DataCompressor/build/MSVC/x64/Release/DCCLI.exe"

script_name="$(basename "$0")"

success="success"

err_msg() {
        echo "Error: $1"
        echo "Linux: $script_name <i386|x86_64|armhf> <IO_SIZE_BITS>"
        echo "Raspberry: $script_name <arm> <IO_SIZE_BITS>"
        echo "Windows: $script_name <win32|x64> <IO_SIZE_BITS>"
}

tests() {
        # arg 1: IO_SIZE_BITS for copy blocksize
        if ! [ $# -eq 1 ] || ! [[ $1 =~ $is_numeric_regex ]]; then
                echo "tests: exactly one numeric argument expected"
                exit 1
        fi

        local result_dega result_lzmh result_copy
        echo "=========================================================="
        echo "testing DEGA"
        echo "=========================================================="
        test_dega result_dega
        echo "=========================================================="
        echo "testing LZMH"
        echo "=========================================================="
        test_lzmh result_lzmh
        echo "=========================================================="
#        echo "testing copy"
#        echo "=========================================================="
#        test_copy "$1" result_copy
#        echo "=========================================================="
#        echo "test results"
#        echo "=========================================================="
        echo "dega: $result_dega"
        echo "lzmh: $result_lzmh"
#        echo "copy: $result_copy"

#        if ! [[ "$result_dega" == "$success" && "$result_lzmh" == "$success" && "$result_copy" == "$success" ]]; then
        if ! [[ "$result_dega" == "$success" && "$result_lzmh" == "$success" ]]; then
                echo "Error. Some tests did not pass."
                exit 1
        fi
}

# #######################################
# start of script.
# #######################################
if ! [ $# -eq 2 ]; then
        err_msg "not enough / too much arguments"
        exit 1
fi

if ! [[ $2 =~ $is_numeric_regex ]] ; then
        err_msg "arg 2 has to be numeric"
        exit 1
fi

platform="$1"
IO_SIZE_BITS="$2"

kernel="$(uname -s)"
machine="$(uname -m)"

if [[ $kernel == Linux* ]]; then
        sep="$linux_dccli_sep"
        dccli_command="$linux_dccli_command"
        if [[ $machine == x86_64 ]]; then

                case "$platform" in
                        "i386")
                                echo "i386"
                                make -C "$linux_dccli_build_dir" clean
                                COMMON_CFLAGS="IO_SIZE_BITS=$IO_SIZE_BITS" CFLAGS="-m32" LDFLAGS="-m32" make -C "$linux_dccli_build_dir" release
                                tests "$IO_SIZE_BITS"

                        ;;
                        "x86_64")
                                echo "x86_64"
                                make -C "$linux_dccli_build_dir" clean
                                COMMON_CFLAGS="IO_SIZE_BITS=$IO_SIZE_BITS" make -C "$linux_dccli_build_dir" release
                                tests "$IO_SIZE_BITS"
                        ;;
                        "armhf")
                                echo "armhf"
                                make -C "$linux_dccli_build_dir" clean
                                COMMON_CFLAGS="IO_SIZE_BITS=$IO_SIZE_BITS" make CC=arm-linux-gnueabihf-gcc -C "$linux_dccli_build_dir" release
                                tests "$IO_SIZE_BITS"
                        ;;
                        *)
                                err_msg "no such target"
                                exit 1
                        ;;
                esac
        elif [[ $machine == armv* ]] || [[ $machine == aarch64 ]]; then
                case "$platform" in
                        "arm")
                                echo "arch: $machine - building on rpi"
                                make -C "$linux_dccli_build_dir" clean
                                COMMON_CFLAGS="IO_SIZE_BITS=$IO_SIZE_BITS" make CC=gcc -C "$linux_dccli_build_dir" release
                                tests "$IO_SIZE_BITS"
                        ;;
                        *)
                                err_msg "on the raspberry pi, we won't build and test other platforms"
                                exit 1
                        ;;
                esac
        fi
elif [[ $kernel == MINGW64* && $machine == x86_64 ]]; then
        sep="$windows_dccli_sep"
        case "$platform" in
                "win32")
                        dccli_command="$win32_dccli_command"
                        echo "win32"
                        bash -c "$windows_compiler $windows_project_file //t:Clean"
                        bash -c "$windows_compiler $windows_project_file //t:Rebuild //p:Configuration=Release //p:Platform=Win32"
                        tests "$IO_SIZE_BITS"
                ;;
                "x64")
                        dccli_command="$win_x64_dccli_command"
                        echo "win x64"
                        bash -c "$windows_compiler $windows_project_file //t:Clean"
                        bash -c "$windows_compiler $windows_project_file //t:Rebuild //p:Configuration=Release //p:Platform=x64"
                        tests "$IO_SIZE_BITS"
                ;;
                *)
                        err_msg "no such target"
                        exit 1
                ;;
        esac
else
        echo "Error. This runs on x86_64 machines, either with linux or windows (mingw)"
        exit 1
fi
