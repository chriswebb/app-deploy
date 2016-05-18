#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <distribution_directory> <deploy_directory> [config file]" 1>&2;
    echo "##teamcity[buildProblem description='Missing parameter options.']";
    exit 0;
fi

DIST_DIR="$1";
DEPLOY_DIR="$2";
CYGPATH="$(/usr/bin/which cygpath)";

if [ -x $CYGPATH ]; then
    CYGWIN="true";
fi

if [ ! -d $DIST_DIR ] && [ $CYGWIN ]; then
    DIST_DIR=`$CYGPATH "$DIST_DIR"`;
fi

if [ ! -d $DIST_DIR ]; then
    echo "Distribution directory '$DIST_DIR' does not exist." 1>&2;
    echo "##teamcity[buildProblem description='Distribution directory $DIST_DIR does not exist.']";
    exit 0;
elif ! find "$DIST_DIR" -mindepth 1 -print -quit | grep -q .; then
    echo "Distribution directory '$DIST_DIR' is empty." 1>&2;
    echo "##teamcity[buildProblem description='Distribution directory $DIST_DIR is empty.']";
    exit 0;
fi


if [ ! -d $DEPLOY_DIR ] && [ $CYGWIN ]; then
    DEPLOY_DIR=`$CYGPATH "$DEPLOY_DIR"`;
fi

if [ ! -d $DEPLOY_DIR ]; then
    echo "Deploy directory '$DEPLOY_DIR' does not exist." 1>&2;
    echo "##teamcity[buildProblem description='Deploy directory $DEPLOY_DIR does not exist.']";
    exit 0;
fi

if [ $# -gt 2 ]; then
    CONFIGFILE="$3";
    if [ ! -f $CONFIGFILE ] && [ $CYGWIN ]; then
        CONFIGFILE=`$CYGPATH "$CONFIGFILE"`;
    fi

    if [ ! -f $CONFIGFILE ]; then
        echo "Config file '$CONFIGFILE' does not exist." 1>&2;
        echo "##teamcity[buildProblem description='Config file $CONFIGFILE does not exist.']";
        exit 0;
    fi
fi

echo "##teamcity[progressMessage 'Copying files from the distribution folder to the deployment folder.']";
if ! cp -R "$DIST_DIR"/* "$DEPLOY_DIR"; then
    echo "Error occurred while copying files from the distribution folder to the deployment folder." 1>&2;
    echo "##teamcity[buildProblem description='Error occurred while copying files from the distribution folder to the deployment folder.']";
    exit 0;
fi

if [ $CONFIGFILE ]; then
    echo "##teamcity[progressMessage 'Copying config file to the deployment folder.']";
    if ! cp "$CONFIGFILE" "$DEPLOY_DIR"; then
        echo "Error occurred while copying config file to the deployment folder." 1>&2;
        echo "##teamcity[buildProblem description='Error occurred while copying config file to the deployment folder.']";
        exit 0;
    fi
fi

echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} application deployed.']";
exit 0;
