#!/usr/bin/env bash

set -euo pipefail
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$workdir/emulator.sh"
checkBitSizePath=".."
source_file="$checkBitSizePath/checkBitSize/checkBitSize.c"

linux_command="$checkBitSizePath/checkBitSize/checkBitSize"

windows_compiler="/c/Program\ Files\ \(x86\)/MSBuild/12.0/Bin/MSBuild.exe"
windows_project_file="$checkBitSizePath/checkBitSize/build/MSVC/checkBitSize.sln"

win32_command="$checkBitSizePath/checkBitSize/build/MSVC/Release/checkBitSize.exe"
win_x64_command="$checkBitSizePath/checkBitSize/build/MSVC/x64/Release/checkBitSize.exe"

script_name="$(basename "$0")"

err_msg() {
        echo "Error: $1"
        echo "Linux: $script_name <i386|x86_64|armhf>"
        echo "Raspberry: $script_name <arm>"
        echo "Windows: $script_name <win32|x64>"
}


# #######################################
# start of script.
# #######################################
if [ ! $# -eq 1 ]; then
        err_msg "not enough / too much arguments"
        exit 1
fi

platform="$1"
kernel="$(uname -s)"
machine="$(uname -m)"

if [[ $kernel == Linux* ]]; then
    command="$linux_command"
    if [[ $machine == x86_64 ]]; then
            case "$platform" in
                "i386")
                    echo "i386"
                    gcc -m32 -o "$command" "$source_file"
                    emulator "$command"

                ;;
                "x86_64")
                    echo "x86_64"
                    gcc -o "$command" "$source_file"
                    emulator "$command"
                ;;
                "armhf")
                    echo armhf
                    arm-linux-gnueabihf-gcc -o "$command" "$source_file"
                    emulator "$command"
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
                                gcc -o "$command" "$source_file"
                                emulator "$command"
                        ;;
                        *)
                                err_msg "on the raspberry pi, we won't build and test other platforms"
                                exit 1
                        ;;
                esac
        fi

elif [[ $kernel == MINGW64* && $machine == x86_64 ]]; then
        case "$platform" in
                "win32")
                        echo "win32"
                        command="$win32_command"
                        bash -c "$windows_compiler $windows_project_file //t:Clean"
                        bash -c "$windows_compiler $windows_project_file //t:Rebuild //p:Configuration=Release //p:Platform=Win32"
                        emulator "$command"
                ;;
                "x64")
                        echo "win x64"
                        command="$win_x64_command"
                        bash -c "$windows_compiler $windows_project_file //t:Clean"
                        bash -c "$windows_compiler $windows_project_file //t:Rebuild //p:Configuration=Release //p:Platform=x64"
                        emulator "$command"
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
