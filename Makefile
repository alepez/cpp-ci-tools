MANTAINER=alepez
IMAGE_NAME=cpp-ci-tools
VERSION=20240515
TAG=${MANTAINER}/${IMAGE_NAME}:${VERSION}

.PHONY: build
build:
	docker build -f Dockerfile -t ${TAG} .

.PHONY: publish
publish: build
	docker push ${TAG}
