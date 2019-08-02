# Basic definitions
DOCKERFILES_DIR := dockerfiles
DOCKER_USERNAME := xddxdd
ARCHITECTURES := amd64 i386 arm32v7 arm64v8
IMAGES := $(subst ${DOCKERFILES_DIR}/,,$(wildcard ${DOCKERFILES_DIR}/*))

# General Purpose Preprocessor config
GPP_INCLUDE_DIR := include
GPP_FLAGS_U := "" "" "(" "," ")" "(" ")" "\#" ""
GPP_FLAGS_M := "\#" "\n" " " " " "\n" "(" ")"
GPP_FLAGS_EXTRA := +c "\\\n" ""
GPP_FLAGS := -I ${GPP_INCLUDE_DIR} --nostdinc -U ${GPP_FLAGS_U} -M ${GPP_FLAGS_M} ${GPP_FLAGS_EXTRA}

# Function to create targets for image/architecture combos
define create-image-arch-target
${DOCKERFILES_DIR}/$1/Dockerfile.$2: ${DOCKERFILES_DIR}/$1/template.Dockerfile
	gpp ${GPP_FLAGS} -D ARCH_$(shell echo $2 | tr a-z A-Z) -o ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ${DOCKERFILES_DIR}/$1/template.Dockerfile || rm -rf ${DOCKERFILES_DIR}/$1/Dockerfile.$2

$1/$2: _crossbuild ${DOCKERFILES_DIR}/$1/Dockerfile.$2
	if [ -z "${BUILD_NUMBER}" ]; then \
		echo "BUILD_NUMBER not set"; \
		exit 1; \
	fi
	if [ -f ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ]; then \
		docker build -t ${DOCKER_USERNAME}/$1:$2-build${BUILD_NUMBER} -f ${DOCKERFILES_DIR}/$1/Dockerfile.$2 ${DOCKERFILES_DIR}/$1 || exit 1; \
		[ -n "${JENKINS_HOME}" ] && docker push ${DOCKER_USERNAME}/$1:$2-build${BUILD_NUMBER} || /bin/true; \
		docker tag ${DOCKER_USERNAME}/$1:$2-build${BUILD_NUMBER} ${DOCKER_USERNAME}/$1:$2 || exit 1; \
		[ -n "${JENKINS_HOME}" ] && docker push ${DOCKER_USERNAME}/$1:$2 || /bin/true; \
	else \
		echo "Dockerfile generation failed, see error above"; \
		if [ -n "${JENKINS_HOME}" ]; then \
			echo "Running in Jenkins CI, failing the build"; \
			exit 1; \
		fi \
	fi

endef

# Function to create targets for images
define create-image-target
$1:$(foreach arch,latest ${ARCHITECTURES},$1/${arch})

# Target for latest image, mapping to amd64
$1/latest: $1/amd64
	docker tag ${DOCKER_USERNAME}/$1:amd64-build${BUILD_NUMBER} ${DOCKER_USERNAME}/$1:build${BUILD_NUMBER} || exit 1
	[ -n "${JENKINS_HOME}" ] && docker push ${DOCKER_USERNAME}/$1:build${BUILD_NUMBER} || /bin/true
	docker tag ${DOCKER_USERNAME}/$1:amd64-build${BUILD_NUMBER} ${DOCKER_USERNAME}/$1:latest || exit 1
	[ -n "${JENKINS_HOME}" ] && docker push ${DOCKER_USERNAME}/$1:latest || /bin/true

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
	docker run --rm --privileged multiarch/qemu-user-static:register --reset >/dev/null

dockerfiles: $(foreach image,${IMAGES},$(foreach arch,${ARCHITECTURES},${DOCKERFILES_DIR}/$(image)/Dockerfile.$(arch)))

images: $(foreach image,${IMAGES},$(image))

clean:
	rm -rf ${DOCKERFILES_DIR}/*/Dockerfile.{i386,amd64,arm32v7,arm64v8}