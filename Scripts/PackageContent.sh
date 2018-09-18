#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$( cd -P "$( dirname "$0" )" && pwd )"
readonly PROGNAME="$( basename "$0" )"
readonly ARGS="$*"

############
# Usage help

#/ Usage: $0 FOLDER
#/ Description:
#/   Merge all Swift files contained in FOLDER into swift code that can be used by the FolderSynchronizer.
#/ Examples: $0 Sources/SourceryRuntime
#/ Options:
#/   FOLDER: the path where the Swift files to merge are
#/   --help,-h: Display this help message
usage() { grep '^#/' "$0" | sed "s/\$0/$PROGNAME/g" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

#########
# Logging

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

#################
# Args processing

process_arguments() {
  local args=
  for arg
  do
    local delim=""
    case "$arg" in
      #translate --gnu-long-options to -g (short options)
      --help)           args="${args}-h ";;
      --debug)          args="${args}-x ";;
      #pass through anything else
      *) [[ "${arg:0:1}" == "-" ]] || delim="\""
          args="${args}${delim}${arg}${delim} ";;
    esac
  done

  #Reset the positional parameters to the short options
  eval set -- $args

  while getopts "hx" OPTION
  do
    case $OPTION in
    x)
      readonly DEBUG='-x'
      set -x
      ;;
    h)
      usage
      exit 0
      ;;
    esac
  done

  #Shift parameters to get the first positional parameter
  shift $((OPTIND-1))
  #Read the 'FOLDER' argument
  readonly FOLDER_PATH=$1
  return 0
}

########
# Script

is_osx() {
  [[ "$(uname)" == 'Darwin' ]]
}

main() {
  process_arguments "$ARGS"
  if [ "$FOLDER_PATH" == "" ]; then fatal "No FOLDER argument provided"; fi
  local folder_glob="${FOLDER_PATH}/*.swift"

  echo "let sourceryRuntimeFiles: [FolderSynchronizer.File] = ["
  for filename in $folder_glob; do
    info "Processing $filename"
    echo "    .init(name: \"$(basename "$filename")\", content:"
    echo "\"\"\""
    if is_osx; then
      < "$filename" sed -E 's=\\([\("n])=\\\\\1=g'
    else
      < "$filename" sed -r 's=\\([\("n])=\\\\\1=g'
    fi
    echo "\"\"\"),"
  done
  echo "]"
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  main "$@"
fi
