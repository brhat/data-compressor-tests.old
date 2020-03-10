#!/usr/bin/env bash
emulator(){
        # checks the executable's  format and the platform we're on.
        # on linux, if i386 or arm, it chooses quemu accordingly.
        # linux x86_64: native
        # windows x64: native
        # win32: we let windows figure it out on it's own.

        # args:
        # first arg: executable
        # 2nd... nth arg: any argument for executable.
        if [ ! $# -ge 1 ]; then
            echo "Error: emulator requires at least one arg."
            echo "Usage: emulator <executable> [args]"
            exit 1
        fi
        echo "choosing emulator for $1"
        echo "file type: $(file -b "$1")"
        local p
        local k
        local m
        k="$(uname -s)"
        m="$(uname -m)"

        if [[ $k == Linux* ]]; then
                p=$(file "$1" | cut -d ',' -f 2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # get second col of "file" output and trim leading and tailing whitespaces
                if [[ $m == x86_64 ]]; then
                        case "$p" in
                                "ARM")
                                        echo "command: $*"
                                        echo "using qemu-arm-static:"
                                        bash -c "qemu-arm-static $*"
                                ;;
                                "Intel 80386")
                                        echo "command: $*"
                                        echo "using qemu-i386-static:"
                                        bash -c "qemu-i386-static $*"
                                ;;
                                "x86-64")
                                        echo "command: $*"
                                        echo "no emulator. x86_64 - native"
                                        bash -c "$*"
                                ;;
                                *)
                                        echo "Emulator: Error: executable was compiled for an unsupported variety of Linux. Target=$p, kernel=$k, machine=$m"
                                        exit 1
                                ;;
                        esac
                elif [[ $m == arm* ]] || [[ $m == aarch64 ]]; then
                        echo "native raspberrypi arch=$m"
                        case "$p" in
                                "ARM" | "ARM aarch64")
                                        echo "command: $*"
                                        echo "no emulator - native."
                                        bash -c "$*"
                                ;;
                                *)
                                        echo "on the raspberry, we do not test other platforms."
                                        exit 1
                                ;;
                        esac

                fi

        elif [[ $k == MINGW64* && $m == x86_64 ]]; then
        echo "command: $*"
                echo "no emulator, windows."
                bash -c "$*"
        else
                echo "Emulator: Error: this platform is not supported. kernel=$k, machine=$m"
                exit 1
        fi
}
