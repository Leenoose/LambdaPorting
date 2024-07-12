#!/bin/bash  
BUILD_PATH=$PWD
ROOT_PATH=$BUILD_PATH
cd $ROOT_PATH

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            --nuget-username)       nuget_username=${VALUE} ;;
            --nuget-token)          nuget_token=${VALUE} ;;
            --nuget-url)            nuget_url=${VALUE} ;;
            --project-path)         project_path=${VALUE} ;;
            --output-path)          output_path=${VALUE} ;;
            *)   
    esac    
done

nuget_source=$nuget_url
nuget_source_name='azure'

dotnet nuget remove source $nuget_source_name

echo "dotnet nuget add source  $nuget_source \
    --name $nuget_source_name \
    --username $nuget_username \
    --password $nuget_token \
    --store-password-in-clear-text"

dotnet nuget add source  $nuget_source \
    --name $nuget_source_name \
    --username $nuget_username \
    --password $nuget_token \
    --store-password-in-clear-text
dotnet nuget list source

export PATH="$PATH:/root/.dotnet/tools"

echo "-----------------------------------------"
echo "Listing: $ROOT_PATH"
echo "-----------------------------------------"

ls $ROOT_PATH

cd $project_path;
dir=$PWD
echo "-----------------------------------------"
echo "Listing: $dir"
echo "-----------------------------------------"

cd $dir
ls $dir
project=$dir
echo "-----------------------------------------"
echo "PACKAGING: $project"
echo "-----------------------------------------"

echo "deleting nuget.config to use default source"
rm nuget.config

echo "Commands"
restore="dotnet restore"
echo $restore
eval $restore



echo "dotnet publish -o $output_path"
dotnet publish -c release /p:GenerateRuntimeConfigurationFiles=true -r linux-x64 --self-contained false -o "$output_path/bin/Release/lambda-publish"

echo "-----------------------------------------"
echo "SHOWING OUTPUT: $output_path"
echo "-----------------------------------------"
ls $output_path

echo "-----------------------------------------"
echo "CLEANING"
echo "-----------------------------------------"
dotnet nuget remove source $nuget_source_name
