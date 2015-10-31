#!/bin/bash

# Daemon that automatically runs every benchmark config files that is dropped into the local/input

initializeWorkingDirAndScriptDir() {
    # Set working directory and remove all symbolic links
    workingDir=`pwd -P`

    # Go the script directory
    cd `dirname $0`
    # If the file itself is a symbolic link (ignoring parent directory links), then follow that link recursively
    # Note that scriptDir=`pwd -P` does not do that and cannot cope with a link directly to the file
    scriptFileBasename=`basename $0`
    while [ -L "$scriptFileBasename" ] ; do
        scriptFileBasename=`readlink $scriptFileBasename` # Follow the link
        cd `dirname $scriptFileBasename`
        scriptFileBasename=`basename $scriptFileBasename`
    done
    # Set script directory and remove other symbolic links (parent directory links)
    scriptDir=`pwd -P`
}
initializeWorkingDirAndScriptDir
optaplannerGitCloneDir="$scriptDir/local/optaplannerGitClone"
inputDir="$scriptDir/local/input"
outputDir="$scriptDir/local/output"


if [ ! -d "$optaplannerGitCloneDir" ]; then
  mkdir -p $optaplannerGitCloneDir
  cd $optaplannerGitCloneDir
  git clone git@github.com:droolsjbpm/optaplanner.git
  cd $scriptDir
fi
mkdir -p $inputDir
mkdir -p $outputDir

cd $optaplannerGitCloneDir/optaplanner
while [ true ] ; do
    echo "Heartbeat at timestamp (`date +%s`)."
    for inputFile in `ls $inputDir` ; do
        timestamp=`date +%s`
        echo "Processing $inputFile"
        git pull --rebase
        if [ $? != 0 ] ; then
            echo "Git pull failed. Sleeping 5 minutes."
            sleep 300
            break
        fi
        mvn clean install -DskipTests
        if [ $? != 0 ] ; then
            echo "Maven failed. Sleeping 5 minutes."
            sleep 300
            break
        fi
        outputTimestampDir="$outputDir/$timestamp"
        mkdir $outputTimestampDir
        mv $inputDir/$inputFile $outputTimestampDir/.
        echo
        echo "Benchmarking..."
    done
    sleep 10
done