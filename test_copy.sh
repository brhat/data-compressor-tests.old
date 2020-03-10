#!/usr/bin/env bash
test_copy() {
        # function to run the copy algorithm on testdata.
        # dccli_command, testdata_input, testdata_output, sep and success are global vars that have to be set in the script sourcing this file.
        # first we check if the command itself fails.
        # in case of success, we run diff and check if it failed.
        # note that we run "set +e" to ignore errors, so you have to use the returnvalue to stop on errors.

        # # usage example:
        # source test_copy.sh
        # declare returnvalue
        # blocksize = 8 # range:1...IO_SIZE_BITS
        # test_copy $blocksize $returnvalue
        # echo "$returnvalue"
        # # end usage example

        # blocksize parameter: https://github.com/CenterForSecureEnergyInformatics/data-compressor/tree/master/DataCompressor/DCLib/doc

        # if successful, returnvalue contains whatever the global success variable contains.
        # in case of failure, returnvalue contains a message with details.

        if ! [ $# -eq 2 ]; then
                echo "test_copy: exeactly two arguments expected."
                echo "test_copy: usage: test_copy <max_blocksize> returnvar"
                exit 1
        fi
        if ! [[ $1 =~ ${is_numeric_regex:?} ]]; then
                echo "test_copy: arg 1 has to be numeric"
                echo "test_copy: usage: test_copy <max_blocksize> returnvar"
                exit 1
        fi

        max_blocksize="$1"

        local __resultvar=$2
        local __result="${success:?}"
        local current_blocksize dccli_return diff_return failed_blocksizes
        failed_blocksizes=()

        # here we run the copy module with blocksize=1...IO_SIZE_BITS
        current_blocksize=1
        while [ "$current_blocksize" -le "$max_blocksize" ]; do
        echo "**********************************************************"
                echo "copy: blocksize=$current_blocksize"
                set +e # start ignoring errors
                emulator "${dccli_command:?}" "${testdata_input:?} ${testdata_output:?} encode copy blocksize=$current_blocksize"
                dccli_return="$?"
                set -e # stop ignoring errors

                if [[ "$dccli_return" -eq 0 ]]; then
                        set +e # start ignoring errors
                        diff -q "${testdata_input:?}" "${testdata_output:?}" # line endings (CRLF / LF) should be the same.
                        diff_return="$?"
                        set -e # stop ignoring errors
                fi
                if ! [ "$dccli_return" -eq "0" ] || ! [ "$diff_return" -eq "0" ]; then
                        failed_blocksizes+=("$current_blocksize")
                fi
                current_blocksize=$((current_blocksize + 1))
        done

        if ! [ ${#failed_blocksizes[@]} -eq 0 ]; then
                __result="Error: Failed blocksizes for copy: ${failed_blocksizes[*]}"
        fi

        eval "$__resultvar='$__result'"
}
