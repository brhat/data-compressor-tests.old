#!/usr/bin/env bash
test_dega() {
        # function to run the dega algorithm on testdata.
        # dccli_command, testdata_input, testdata_output, sep and success are global vars that have to be set in the script sourcing this file.
        # first we check if the command itself fails.
        # in case of success, we run diff and check if it failed.
        # note that we run "set +e" to ignore errors, so you have to use the returnvalue to stop on errors.

        # # usage example:
        # source test_dega.sh
        # declare returnvalue
        # test_dega $returnvalue
        # echo "$returnvalue"
        # # end usage example

        # if successful, returnvalue contains whatever the global success variable contains.
        # in case of failure, returnvalue contains a message with details.

        if ! [ $# -eq 1 ]; then
                echo "test_dega: exactly one argument (variable for the result) expected"
                exit 1
        fi
        local __resultvar=$1
        local __result="${success:?}"
        local dccli_return diff_return

        set +e # start ignoring errors
        emulator "${dccli_command:?}" "${testdata_input:?} ${testdata_output:?} decode csv ${sep:?} encode normalize ${sep:?} encode diff ${sep:?} encode seg ${sep:?} encode bac adaptive ${sep:?} decode bac adaptive ${sep:?} decode seg ${sep:?} decode diff ${sep:?} decode normalize ${sep:?} encode csv"
        dccli_return="$?"
        set -e # stop ignoring errors


        if [[ "$dccli_return" -eq 0 ]]; then
                set +e # start ignoring errors
                # depending on windows / linux line endings might differ. copy and lzmh should preserve line endings.
                # because of that we ignore trailing CRs on windows
                if [[ $(uname -s) == Linux* ]]; then
                        diff -q "${testdata_input:?}" "${testdata_output:?}"
                else
                        diff -q --strip-trailing-cr "${testdata_input:?}" "${testdata_output:?}"
                fi
                diff_return="$?"
                set -e # stop ignoring errors
                if ! [[ "$diff_return" -eq 0 ]]; then
                        __result="Error: diff failed with status $diff_return"
                fi
        else
                __result="Error: dccli failed with status $dccli_return"
        fi

        eval "$__resultvar='$__result'"
}

