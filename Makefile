IMAGE_NAME := gorky/resumed-nllb
TAG := latest
MODEL_NAME := facebook/nllb-200-distilled-600M
SRC_LANG := pol_Latn
TGT_LANG := eng_Latn
HF_CACHE := ${HOME}/.cache/huggingface
PORT := 8888

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

.PHONY: build run test clean

# Local build with cache
build:
	@echo "Building with cache at ${HF_CACHE}"
	@mkdir -p ${HF_CACHE}
	docker build \
		--build-arg MODEL_NAME=${MODEL_NAME} \
		--build-arg SRC_LANG=${SRC_LANG} \
		--build-arg TGT_LANG=${TGT_LANG} \
		--build-arg HF_HOME=/hf-cache \
		--tag ${IMAGE_NAME}:${TAG} \
		.

# Build with explicit cache mounting (faster subsequent builds)
build-with-cache:
	@echo "Building with explicit cache mounting"
	@mkdir -p ${HF_CACHE}
	DOCKER_BUILDKIT=1 docker build \
		--progress=plain \
		--build-arg MODEL_NAME=${MODEL_NAME} \
		--build-arg SRC_LANG=${SRC_LANG} \
		--build-arg TGT_LANG=${TGT_LANG} \
		--build-arg HF_HOME=/hf-cache \
		--tag ${IMAGE_NAME}:${TAG} \
		--cache-from type=local,src=${HF_CACHE} \
		.

# Build without cache (for CI)
build-nocache:
	@echo "Building without cache (CI mode)"
	docker build \
		--no-cache \
		--build-arg MODEL_NAME=${MODEL_NAME} \
		--build-arg SRC_LANG=${SRC_LANG} \
		--build-arg TGT_LANG=${TGT_LANG} \
		--tag ${IMAGE_NAME}:${TAG} \
		.

run:
	@echo "Running container with port ${PORT} and cache at ${HF_CACHE}"
	docker run -it --rm \
		-p ${PORT}:8080 \
		-v ${HF_CACHE}:/hf-cache \
		-e MODEL_NAME=${MODEL_NAME} \
		-e SRC_LANG=${SRC_LANG} \
		-e TGT_LANG=${TGT_LANG} \
		${IMAGE_NAME}:${TAG}

test:
	@echo "Testing container..."
	# Add your test commands here
	@echo "Tests completed"

clean:
	@echo "Cleaning up containers using the image..."
	@-docker ps -a -q --filter ancestor=${IMAGE_NAME}:${TAG} | xargs -r docker stop 2>/dev/null
	@-docker ps -a -q --filter ancestor=${IMAGE_NAME}:${TAG} | xargs -r docker rm 2>/dev/null
	@echo "Removing the image..."
	@-docker rmi ${IMAGE_NAME}:${TAG} 2>/dev/null || echo "Image already removed or not present"
	@-docker image ls
	@echo "Cleanup complete"

build-base:
	docker compose -f compose-dev.yml build nllb-base

bb:
	docker build \
	--platform linux/arm64 \
	-f Dockerfile.base \
	-t resumed-nllb-base:latest \
	.

build-app:
	DOCKER_BUILDKIT=0 docker compose -f compose-dev.yml build nllb-pl-en

ba:
	docker build \
	--build-arg BASE_IMAGE=resumed-nllb-base \
	-f Dockerfile \
	-t resumed-nllb:latest \
	.

run-app:
	docker compose -f compose-dev.yml up nllb-pl-en