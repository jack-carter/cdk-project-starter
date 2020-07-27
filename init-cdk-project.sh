# !/bin/bash
ARGV=($@) ; [[ "${ARGV[@]}" =~ "--debug" ]] && __debug=on

DEBUG() { [[ "${__debug}" == "on" ]] && echo "[DEBUG] $@"; }

# Local Functional Helpers
DEBUG defining internal functions ...

LOG() { 
    __level=$1 ;  __tag=$2 ; shift 2;

    if ([ "_${__debug}" == "_on" ] || [ $log_level -ge $__level ]) ; then
        __message="$@"
        printf "[%5s] %s\n" "${__tag}" "${__message}";
        unset __message
    fi 

    unset __tag ; unset __level
}

LOG_LEVEL() {
    __level=$1

    case "$__level" in
        error) log_level=1;;
        warn)  log_level=2;;
        info)  log_level=3;;
        trace) log_level=4;;
        *)     log_level=3;;
    esac

    [[ "${__debug}" == "on" ]] && log_level=99

    unset __level
}

ERROR() { LOG 1 "ERROR" $@; }
WARN()  { LOG 2 "WARN" $@; }
INFO()  { LOG 3 "INFO" $@; }
TRACE() { LOG 4 "TRACE" $@; }

RUN()   { INFO "$@"; [[ ! "_$run_state" == "_dry" ]] && "$@"; }
VAR()   { var=$1; TRACE "\$${var}: ${!var}"; }

DEFAULT() {
    __variable=$1 ; __default=$2
    [[ -z "${!__variable}" ]] && eval "$__variable"="$__default"
    unset __variable ; unset __default
}

REQUIRE() { 
    param=$1; shift;
    [[ -z "${!param}" ]] && echo "$@" && exit
    unset param
}

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
DEBUG parsing command line arguments ...
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
DEBUG setting positional arguments ...
project=$1

DEBUG setting defaults ...
DEFAULT packager npm
DEFAULT language typescript
DEFAULT log_opt warn
DEFAULT conventions all
DEFAULT run_state full

LOG_LEVEL $log_opt

# Show Settings
DEBUG showing settings ...
VAR project
VAR packager
VAR language
VAR log_level
VAR conventions
VAR run_state

# Check Settings
DEBUG checking required settings ...
REQUIRE project "Usage: ${0} <project>"

# Fast-Fail when missing key commands
DEBUG verifying required installations ...
INSTALLED cdk
CHECK_PACKAGER npm
CHECK_PACKAGER yarn

# Guard any existing projects
DEBUG checking for existing project ...
[[ -d "$project" ]] && ERROR "'${project}' already exists." && exit

# CDK Initialization
DEBUG initializing CDK project ...
RUN mkdir $project
RUN cd $project
RUN cdk init app --language $language
RUN $packager run build
RUN cdk list

# Conform to testing conventions
DEBUG creating test folders ...
RUN mkdir -p src/__tests__
RUN mkdir -p src/__fixtures__
RUN mkdir -p test/e2e
RUN mkdir -p test/iac
RUN mkdir -p test/__fixtures__

echo -e "\n${project} is now initialized\n"

# Clean-up
DEBUG cleaning up ...
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
unset -f REQUIRE
unset -f DEFAULT

unset -f VAR
unset -f RUN

unset -f ERROR
unset -f WARN
unset -f INFO
unset -f TRACE

unset -f LOG