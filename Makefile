# Basic definitions
DOCKERFILES_DIR := dockerfiles
DOCKER_USERNAME := xddxdd
ARCHITECTURES := amd64 i386 arm32v7 arm64v8 ppc64le s390x riscv64 x32
IMAGES := $(subst ${DOCKERFILES_DIR}/,,$(wildcard ${DOCKERFILES_DIR}/*))

ifeq ($(wildcard /var/run/docker-ram/docker.sock),)
	DOCKER_HOST = unix:///var/run/docker.sock
else
	DOCKER_HOST = unix:///var/run/docker-ram/docker.sock
endif

# General Purpose Preprocessor config
GPP_INCLUDE_DIR := include
GPP_FLAGS_U := "" "" "(" "," ")" "(" ")" "\#" ""
GPP_FLAGS_M := "\#" "\n" " " " " "\n" "(" ")"
GPP_FLAGS_EXTRA := +c "\\\n" ""
GPP_FLAGS := -I ${GPP_INCLUDE_DIR} --nostdinc -U ${GPP_FLAGS_U} -M ${GPP_FLAGS_M} ${GPP_FLAGS_EXTRA}

BUILD_DATE ?= $(shell date +%Y%m%d%H%M)

# Function to create targets for image/architecture combos
define create-image-arch-target
${DOCKERFILES_DIR}/$1/Dockerfile.$2: ${DOCKERFILES_DIR}/$1/template.Dockerfile
	@gpp ${GPP_FLAGS} -D ARCH_$(shell echo $2 | tr a-z A-Z) -o ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ${DOCKERFILES_DIR}/$1/template.Dockerfile || rm -rf ${DOCKERFILES_DIR}/$1/Dockerfile.$2

$1/$2: ${DOCKERFILES_DIR}/$1/Dockerfile.$2
	@export DOCKER_HOST=${DOCKER_HOST}; \
	if [ -f ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ]; then \
		docker build --pull --no-cache --squash -t ${DOCKER_USERNAME}/$1:$2-${BUILD_DATE} -f ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ${DOCKERFILES_DIR}/$1 || exit 1; \
		echo "Docker Hub"; \
			[ -z "${CI}" ] || docker push ${DOCKER_USERNAME}/$1:$2-${BUILD_DATE} && /bin/true; \
			docker tag ${DOCKER_USERNAME}/$1:$2-${BUILD_DATE} ${DOCKER_USERNAME}/$1:$2 || exit 1; \
			[ -z "${CI}" ] || docker push ${DOCKER_USERNAME}/$1:$2 && /bin/true; \
	else \
		echo "Dockerfile generation failed, see error above"; \
		exit 1; \
	fi

endef

# Function to create targets for images
define create-image-target
$1:$(foreach arch,latest ${ARCHITECTURES},$1/${arch})

# Target for latest image, mapping to amd64
$1/latest: $1/amd64
	@DOCKER_HOST=${DOCKER_HOST} docker tag ${DOCKER_USERNAME}/$1:amd64-${BUILD_DATE} ${DOCKER_USERNAME}/$1:${BUILD_DATE} || exit 1
	[ -z "${CI}" ] || DOCKER_HOST=${DOCKER_HOST} docker push ${DOCKER_USERNAME}/$1:${BUILD_DATE} && /bin/true
	@DOCKER_HOST=${DOCKER_HOST} docker tag ${DOCKER_USERNAME}/$1:amd64-${BUILD_DATE} ${DOCKER_USERNAME}/$1:latest || exit 1
	[ -z "${CI}" ] || DOCKER_HOST=${DOCKER_HOST} docker push ${DOCKER_USERNAME}/$1:latest && /bin/true

$(foreach arch,${ARCHITECTURES},$(eval $(call create-image-arch-target,$1,$(arch))))
endef

# By default, build docker images, and do not delete intermediate files
.DEFAULT_GOAL := images
.DELETE_ON_ERROR:
.SECONDARY:

# Create all targets for image/architecture combos
$(foreach image,${IMAGES},$(eval $(call create-image-target,${image})))

# Target to enable multiarch support
_crossbuild:
	@DOCKER_HOST=${DOCKER_HOST} docker run --rm --privileged multiarch/qemu-user-static --reset -p yes >/dev/null

dockerfiles: $(foreach image,${IMAGES},$(foreach arch,${ARCHITECTURES},${DOCKERFILES_DIR}/$(image)/Dockerfile.$(arch)))

images: $(foreach image,${IMAGES},$(image))

clean:
	@rm -rf ${DOCKERFILES_DIR}/*/Dockerfile.{$(shell echo ${ARCHITECTURES} | sed "s/ /,/g")}

touch:
	@dd if=/dev/urandom of=.touch bs=4K count=1
