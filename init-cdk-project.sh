# !/bin/bash

#
# Local Functional Helpers
#
LOG() { 
    __level=$1; 
    __tag=$2; 
    shift 2;

    [ $log_level -ge $__level ] && echo "[${__tag}] $@";

    unset __tag
    unset __level
}

ERROR() { LOG 1 "ERROR" $@; }
WARN()  { LOG 2 "WARN" $@; }
INFO()  { LOG 3 "INFO" $@; }
TRACE() { LOG 4 "TRACE" $@; }

RUN()   { INFO "$@"; [[ ! "_$run_state" == "_dry" ]] && "$@"; }
VAR()   { var=$1; TRACE "\$${var}: ${!var}"; }

INSTALLED() {
    if [[ -z `command -v ${1}` && -z `which ${1}` ]] ; then
        echo "ERROR: '${1}' is not installed."
        exit
    fi
}

CHECK_PACKAGER() {
    [[ "$packager" == "$1" ]] && INSTALLED $1
}

# Command Line Arguments
LOG_OPTIONS=(error warn info trace)
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
            shift ; run_state=dry ;;
        -*) 
            shift ;;
        *) 
            POSITIONAL+=("$1") ; shift ;;
    esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# Positional Arguments
project=$1

# Check Settings & Set Defaults
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

# Show Settings
VAR project
VAR packager
VAR language
VAR log_level
VAR conventions
VAR run_state

# Fast-Fail when missing key commands
INSTALLED cdk
CHECK_PACKAGER npm
CHECK_PACKAGER yarn

# Guard any existing projects
[[ -d "$project" ]] && ERROR "'${project}' already exists." && exit

# CDK Initialization
RUN mkdir $project
RUN cd $project
RUN cdk init app --language $language
RUN $packager run build
RUN cdk list

# Conform to testing conventions
RUN mkdir -p src/__tests__
RUN mkdir -p src/__fixtures__
RUN mkdir -p test/e2e
RUN mkdir -p test/iac
RUN mkdir -p test/__fixtures__

# Clean-up
unset log_level
unset run_state
unset conventions
unset log_opt
unset language
unset packager
unset project

unset POSITIONAL
unset LOG_OPTIONS

unset -f CHECK_PACKAGER
unset -f INSTALLED

unset -f VAR
unset -f RUN

unset -f ERROR || unset LOG_ERROR
unset -f WARN  || unset LOG_WARN
unset -f INFO  || unset LOG_INFO
unset -f TRACE || unset LOG_TRACE

unset -f LOG