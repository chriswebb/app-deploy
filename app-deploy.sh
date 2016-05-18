#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <distribution_directory> <deploy_directory> [config file]" 1>&2;
    echo "##teamcity[buildProblem description='Missing parameter options.']";
    exit 1;
fi

if [ ! -d $1 ]; then
    echo "Distribution directory '$1' does not exist." 1>&2;
    echo "##teamcity[buildProblem description='Distribution directory &apos;$1&apos; does not exist.']";
    exit 1;
elif ! find "$1" -mindepth 1 -print -quit | grep -q .; then
    echo "Distribution directory '$1' is empty." 1>&2;
    echo "##teamcity[buildProblem description='Distribution directory &apos;$1&apos; is empty.']";
    exit 1;
fi

if [ ! -d $2 ]; then
    echo "Deploy directory '$2' does not exist." 1>&2;
    echo "##teamcity[buildProblem description='Deploy directory &apos;$2&apos; does not exist.']";
    exit 1;
fi

if [ $# -gt 2 ] && [ ! -f $3 ]; then
    echo "Config file '$3' does not exist." 1>&2;
    echo "##teamcity[buildProblem description='Config file &apos;$3&apos; does not exist.']";
    exit 1;
elif [ $# -gt 2 ]; then
    CONFIGFILE="$3";
fi

echo "##teamcity[progressMessage 'Copying files from the distribution folder to the deployment folder.']";
if ! cp "$1"/* "$2"; then
    echo "Error occurred while copying files from the distribution folder to the deployment folder." 1>&2;
    echo "##teamcity[buildProblem description='Error occurred while copying files from the distribution folder to the deployment folder.']";
    exit 1;
fi

if [ $CONFIGFILE ]; then
    echo "##teamcity[progressMessage 'Copying config file to the deployment folder.']";
    if ! cp "$CONFIGFILE" "$2"; then
        echo "Error occurred while copying config file to the deployment folder." 1>&2;
        echo "##teamcity[buildProblem description='Error occurred while copying config file to the deployment folder.']";
        exit 1;
    fi
fi

echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} application deployed.']";
exit 0;
