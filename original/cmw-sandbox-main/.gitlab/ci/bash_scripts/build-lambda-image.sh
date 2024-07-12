#!/bin/bash 
set -eo pipefail

BUILD_PATH=$PWD
ROOT_PATH=$BUILD_PATH
cd $ROOT_PATH

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            --project-path)         project_path=${VALUE} ;;
            --output-path)          output_path=${VALUE} ;;
            --app-name)             app_name=${VALUE} ;;
            --aws-region)           aws_region=${VALUE} ;;
            --ecr-repository-name)  ecr_repository_name=${VALUE} ;;
            --ci_build_number)      ci_build_number=${VALUE} ;;
            *)   
    esac    
done

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

echo "-----------------------------------------"
echo "SHOWING OUTPUT: $output_path"
echo "-----------------------------------------"
ls $output_path

echo "-----------------------------------------"
echo "DOCKER BUILD"
echo "-----------------------------------------"
echo "docker info"
docker info

pushd $output_path
ls
echo "docker build -f $dir/Dockerfile -t $app_name-ci-$ci_build_number ."
docker build -f $dir/Dockerfile -t $app_name-ci-$ci_build_number .
popd

echo "-----------------------------------------"
echo "SHOWING DOCKER IMAGES"
echo "-----------------------------------------"
docker images -a

echo "-----------------------------------------"
echo "DOCKER TAG TO AWS ECR"
echo "-----------------------------------------"
echo "tag docker to aws ecr repo"
docker login -u AWS -p $(cat $output_path/token.txt) $ecr_repository_name
echo "tag = $app_name-ci-$ci_build_number"
echo "image = $ecr_repository_name:$app_name-ci-$ci_build_number"
docker tag $app_name-ci-$ci_build_number $ecr_repository_name:$app_name-ci-$ci_build_number

echo "-----------------------------------------"
echo "SHOWING DOCKER IMAGES"
echo "-----------------------------------------"
docker images -a

echo "-----------------------------------------"
echo "DOCKER PUSH TO AWS"
echo "-----------------------------------------"
echo "docker push to aws"
docker push $ecr_repository_name:$app_name-ci-$ci_build_number

echo "done"