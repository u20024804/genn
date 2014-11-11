#!/bin/bash

# BASH SCRIPT TO LINK SPINEML TO GENN
# ALEX COPE - 2013-2014
# UNIVERSITY OF SHEFFIELD

#exit on first error
set -e

MODEL_DIR=$PWD"/model"
LOG_DIR=$PWD"/temp"

# get the command line options...
while getopts w:srm:o:n:a:vV\? opt
do
case "$opt" in
w)  GENN_2_BRAHMS_DIR="$OPTARG"
;;
s)  REBUILD_SYSTEMML="false"
;;
r)  REBUILD_COMPONENTS="true"
;;
m)  MODEL_DIR="$OPTARG"
;;
o)  OUTPUT_DIR="$OPTARG"
;;
n)  NODES="$OPTARG"
;;
a)  NODEARCH="$OPTARG"
;;
v)  VERBOSE_BRAHMS="--d"
;;
V)  VERBOSE_BRAHMS="--dd"
;;
\?) usage
;;
esac
done
shift `expr $OPTIND - 1`

# What OS are we?
if [ $(uname) = 'Linux' ]; then
if [ $(uname -i) = 'i686' ]; then
OS='Linux'
else
OS='Linux'
fi
elif [ $(uname) = 'Windows_NT' ] || [ $(uname) = 'MINGW32_NT-6.1' ]; then
OS='Windows'
else
OS='OSX'
fi

echo "*Running XSLT" > $MODEL_DIR/time.txt

echo ""
echo "Converting SpineML to GeNN"
echo "Alex Cope             2014"
echo "##########################"
echo ""
echo "Creating extra_neurons.h file with new neuron_body components..."
xsltproc -o extra_neurons.h SpineML_2_GeNN_neurons.xsl model/experiment.xml
echo "Done"
echo "Creating extra_postsynapses.h file with new postsynapse components..."
xsltproc -o extra_postsynapses.h SpineML_2_GeNN_postsynapses.xsl model/experiment.xml
echo "Done"
echo "Creating extra_weightupdates.h file with new weightupdate components..."
xsltproc -o extra_weightupdates.h SpineML_2_GeNN_weightupdates.xsl model/experiment.xml
echo "Done"
echo "Creating model.cc file..."
xsltproc -o model.cc SpineML_2_GeNN_model.xsl model/experiment.xml
echo "Done"
echo "Creating sim.cu file..."
xsltproc --stringparam model_dir "$MODEL_DIR" --stringparam log_dir "$LOG_DIR" -o sim.cu SpineML_2_GeNN_sim.xsl model/experiment.xml
echo "Done"
#exit(0)
echo "Running GeNN code generation..."
if [[ -z ${GENN_PATH+x} ]]; then
echo "Sourcing .bashrc as environment does not seem to be correct"
source ~/.bashrc
fi
if [[ -z ${GENN_PATH+x} ]]; then
error_exit "The system environment is not correctly configured"
fi

# make athe dir for the logs
mkdir -p temp

#check the directory is there
mkdir -p $GENN_PATH/userproject/model_project
cp extra_neurons.h $GENN_PATH/lib/include/
cp extra_postsynapses.h $GENN_PATH/lib/include/
cp extra_weightupdates.h $GENN_PATH/lib/include/
cp rng.h $GENN_PATH/userproject/model_project/
cp Makefile $GENN_PATH/userproject/model_project/
cp model.cc $GENN_PATH/userproject/model_project/model.cc
cp sim.cu $GENN_PATH/userproject/model_project/sim.cu
if cp model/*.bin $GENN_PATH/userproject/model_project/; then
	echo "Copying binary data..."	
fi

echo "*GeNN code-gen" > $MODEL_DIR/time.txt

cd $GENN_PATH/userproject/model_project
../../lib/bin/buildmodel.sh model $DBGMODE

echo "*Compiling..." > $MODEL_DIR/time.txt
make clean
make

#if [ $OS = 'Linux' ]; then
#if mv *.bin bin/linux/release/; then
#	echo "Moving binary data..."	
#fi
#cd bin/linux/release
#fi
#if [ $OS = 'OSX' ]; then
#if mv *.bin bin/darwin/release/; then
#echo "Moving binary data..."
#fi
#cd bin/darwin/release
#fi
./sim
#rm *.bin
echo "Done"
echo ""
echo "Finished"
