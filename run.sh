#!/bin/sh

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

gitCloneDir="$scriptDir/local/gitClone"
inputDir="$scriptDir/local/input"
processedDir="$scriptDir/local/processed"
outputDir="$scriptDir/local/output"
. ./default.local.properties
if [ -f local.properties ]; then
  . ./local.properties
fi

if [ ! -d "$gitCloneDir" ]; then
  mkdir -p $gitCloneDir
  cd $gitCloneDir
  git clone $gitCloneUrl
  cd $scriptDir
fi
mkdir -p $inputDir
mkdir -p $processedDir
mkdir -p $outputDir

cd $gitCloneDir/$projectDir
while [ true ] ; do
    echo "Heartbeat at timestamp (`date +%s`)."
    for inputFile in `ls $inputDir` ; do
        echo "Processing $inputFile"
        git pull --rebase
        if [ $? != 0 ] ; then
            echo "Git pull failed. Sleeping 5 minutes."
            sleep 300
            break
        fi
        $M3_HOME/bin/mvn -U clean install -DskipTests
        if [ $? != 0 ] ; then
            echo "Maven failed. Sleeping 5 minutes."
            sleep 300
            break
        fi
        mv $inputDir/$inputFile $processedDir/$inputFile
        echo
        echo "Benchmarking..."
        cd $modulePath
        $M3_HOME/bin/mvn exec:exec -Dexec.executable="java" -Dexec.args="-cp %classpath $VM_OPTS org.optaplanner.benchmark.impl.cli.OptaPlannerBenchmarkCli $processedDir/$inputFile $outputDir"
        if [ $? != 0 ] ; then
            echo "Benchmarking failed. Skipping inputfile ($inputFile)."
            echo $? > $processedDir/failed_$inputFile
        fi
        cd ..
    done
    sleep 10
done
