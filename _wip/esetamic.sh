#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#/ esematic
#/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#/ Description: Used for setting up statamic sites on our vps 
#/              from a repositories staging or production branch.
#/              Our vps normally serves public_html so we fix that
#/              by making an /app folder in ~/domains/[domain]/ 
#/              and symbolic linking the /app/public with the 
#/              public_html folder.
#/ Options:     
#/              -s Setup staging branch
#/              -p Setup production branch
#/              --help: Display this help message
#/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Help command
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

# Variables
BRANCH=
REPO=
DOMAIN=

echoerr() { printf "%s\n" "$*" >&2 ; }
info()    { echoerr "[INFO]    $*" ; }
warning() { echoerr "[WARNING] $*" ; }
error()   { echoerr "[ERROR]   $*" ; }
fatal()   { echoerr "[FATAL]   $*" ; exit 1 ; }

has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

cleanup() {
  # Remove temporary files
  # Restart services
  info "cleaned up"
}

ask(){
    echo '[INPUT] What repository are we using?'
    read REPO
    echo '[INPUT] What domain should we use?'
    read DOMAIN
}

checkdomain(){
    # TODO: Change all these this for running on our real vps
    if [ ! -d "./test/domains/$DOMAIN" ] 
    then
        fatal "Domain $DOMAIN DOES NOT exists on this server." 
    fi
    if [ -d "./test/domains/$DOMAIN/app" ] 
    then
        fatal "There is already an app living in $DOMAIN" 
    fi
    if [ ! -d "./test/domains/$DOMAIN" ] 
    then
        fatal "Domain $DOMAIN DOES NOT exists on this server." 
    fi
}

deploy(){
    info 'oh hi'
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then

  # Check for params
  if [ $# -eq 0 ]
    then
        usage;
  fi

  trap cleanup EXIT

  # Staging
  if has_param '-s' "$@"; then
    info 'Setup staging'
    BRANCH="staging"
    ask
    checkdomain
    deploy
    info 'Staging deployed, cleaning up'
    exit 0
  fi

  # Production
  if has_param '-p' "$@"; then
    info 'Setup production'
    BRANCH="production"
    ask
    checkdomain
    deploy
    info 'Production deployed, cleaning up'
    exit 0
  fi
fi

error 'No branch specified'