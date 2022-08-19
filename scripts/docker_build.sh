
docker buildx build --platform linux/arm64,linux/amd64 --push -t cpp-build-env -f Dockerfile .