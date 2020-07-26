# !/bin/bash

#
# Local Functional Helpers
#
ERROR() { # log_level=1
    [ $log_level -ge 1 ] && echo "[ERROR] $@"
}

WARN() { # log_level=2
    [ $log_level -ge 2 ] && echo "[WARN] $@"
}

INFO() { # log_level=3
    [ $log_level -ge 3 ] && echo "[INFO] $@"
}

TRACE() { # log_level=4
    [ $log_level -ge 4 ] && echo "[TRACE] $@"
}

CHECK() {
    [[ "$packager" == "$1" && -z `command -v ${1}` && -z `which ${1}` ]] && echo "ERROR: '${1}' is not installed." && exit
}

#
# System Checks
#
[[ -z `command -v cdk` && -z `which cdk` ]] && echo "ERROR: the AWS CDK doesn't seem to be installed" && exit

#
# Process all Command Line Arguments
#
LOG_OPTIONS=("error" "warn" "info" "trace")
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -?|--help)
            echo "Usage: ${0} [--npm | --yarn] [--language <language>] [--log <error | warn | info | trace>]<project-name>" ; exit ;;
        --yarn) 
            shift ; packager=yarn ;;
        --npm) 
            shift ; packager=npm ;;
        --conv|--conventions) # all|tests
            shift ; conventions=$1 ; shift ;;
        --lang|--language) # typescript|javascript|...
            shift ; language=$1 ; shift ;;
        --log) # error|warn|info|trace
            shift ; [[ "${LOG_OPTIONS[@]}" =~ "$1" ]] && log_opt=$1 ; shift ;;
        --dry-run)
            shift ; run_state=dry_run ;;
        -*) 
            shift ;;
        *) 
            POSITIONAL+=("$1") ; shift ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

#
# Positional Arguments
#
project=$1

#
# Check Settings & Set Defaults
#
[[ -z "$project" ]] && echo "Usage: ${0} <project-name>" && exit
[[ -z "$packager" ]] && packager=npm
[[ -z "$language" ]] && language=typescript
[[ -z "$log_opt" ]] && log_opt=warn
[[ -z "$conventions" ]] && conventions=all
[[ -z "$run_state" ]] && run_state=full

case "$log_opt" in
    error) log_level=1 ;;
    warn)  log_level=2 ;;
    info)  log_level=3 ;;
    trace) log_level=4 ;;
    *)     log_level=2 ;;
esac

#
# Check for Packager Availability
#
CHECK npm
CHECK yarn

#
# Show Settings
#
TRACE "Project: ${project}"
TRACE "Packager: ${packager}"
TRACE "Language: ${language}"
TRACE "Log level: ${log_level}"
TRACE "Conventions: ${conventions}"
TRACE "Run state: ${run_state}"

#
# Init the project
#
if [[ ! "${run_state}" == "full" ]]; then
    [[ -d "$project" ]] && ERROR "'${project}' already exists." && exit

    mkdir $project
    cd $project
    init app --language $language
    $packager run build
    cdk list

    mkdir -p src/__tests__
    mkdir -p src/__fixtures__
    mkdir -p test/e2e
    mkdir -p test/iac
    mkdir -p test/__fixtures__
fi 

#
# Clean-up
#
unset project
unset conventions_only
unset log_opt
unset log_level
unset POSITIONAL
unset LOG_OPTIONS

unset -f CHECK_PACKAGER

unset -f ERROR || unset LOG_ERROR
unset -f WARN  || unset LOG_WARN
unset -f INFO  || unset LOG_INFO
unset -f TRACE || unset LOG_TRACE