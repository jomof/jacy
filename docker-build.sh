TARGET=$1
SHORT_SHA=${SHORT_SHA:-local-build-short-sha}
DOCKER_BASE=gcr.io/$PROJECT_ID/$TARGET
docker pull $DOCKER_BASE
docker build \
--cache-from=$DOCKER_BASE:latest \
-f ./DockerFiles/$TARGET/DockerFile \
-t $DOCKER_BASE \
-t $DOCKER_BASE:latest \
-t $DOCKER_BASE:$BUILD_ID \
-t $DOCKER_BASE:$SHORT_SHA \
.

docker push $DOCKER_BASE
docker push $DOCKER_BASE:latest
docker push $DOCKER_BASE:$BUILD_ID
docker push $DOCKER_BASE:$SHORT_SHA

mkdir data/
id=$(docker create $DOCKER_BASE)
docker cp $id:/data/ace-0.9.30-x86-64.tar.gz data/
docker cp $id:/data/jacy.dat data/
docker rm -v $id

gsutil cp -r data/* gs://my-web-apis_cloudbuild/artifacts/jacy-dat/latest


