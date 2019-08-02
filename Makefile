GPP_INCLUDE_DIR := include
GPP_FLAGS_U := "" "" "(" "," ")" "(" ")" "\#" ""
GPP_FLAGS_M := "\#" "\n" " " " " "\n" "(" ")"
GPP_FLAGS := -I ${GPP_INCLUDE_DIR} --nostdinc -U ${GPP_FLAGS_U} -M ${GPP_FLAGS_M}
DOCKERFILES_DIR := dockerfiles
DOCKER_BUILD_FLAG := .docker
DOCKER_USERNAME := xddxdd

SUBDIRS := $(wildcard ${DOCKERFILES_DIR}/*)

.SECONDARY:

# AMD x86-64 architecture
${DOCKERFILES_DIR}/%/Dockerfile.amd64: ${DOCKERFILES_DIR}/%/template.Dockerfile
	gpp ${GPP_FLAGS} -D ARCH_AMD64 -o $@ $<

${DOCKER_BUILD_FLAG}/%/amd64: ${DOCKERFILES_DIR}/%/Dockerfile.amd64
	$(eval IMAGE := ${word 2,${subst /, ,$@}})
	docker build -t ${DOCKER_USERNAME}/${IMAGE}:amd64-build${BUILD_NUMBER} -f ${DOCKERFILES_DIR}/${IMAGE}/Dockerfile.amd64 ${DOCKERFILES_DIR}/${IMAGE}
	docker push ${DOCKER_USERNAME}/${IMAGE}:amd64-build${BUILD_NUMBER}
	docker tag ${DOCKER_USERNAME}/${IMAGE}:amd64-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:amd64
	docker push ${DOCKER_USERNAME}/${IMAGE}:amd64
	# AMD64 special
	docker tag ${DOCKER_USERNAME}/${IMAGE}:amd64-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:build${BUILD_NUMBER}
	docker push ${DOCKER_USERNAME}/${IMAGE}:build${BUILD_NUMBER}
	docker tag ${DOCKER_USERNAME}/${IMAGE}:amd64-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:latest
	docker push ${DOCKER_USERNAME}/${IMAGE}:latest
	@mkdir -p ${DOCKER_BUILD_FLAG}/${IMAGE}
	@touch $@

# Intel i386 architecture
${DOCKERFILES_DIR}/%/Dockerfile.i386: ${DOCKERFILES_DIR}/%/template.Dockerfile
	gpp ${GPP_FLAGS} -D ARCH_I386 -o $@ $<

${DOCKER_BUILD_FLAG}/%/i386: ${DOCKERFILES_DIR}/%/Dockerfile.i386
	$(eval IMAGE := ${word 2,${subst /, ,$@}})
	docker build -t ${DOCKER_USERNAME}/${IMAGE}:i386-build${BUILD_NUMBER} -f ${DOCKERFILES_DIR}/${IMAGE}/Dockerfile.i386 ${DOCKERFILES_DIR}/${IMAGE}
	docker push ${DOCKER_USERNAME}/${IMAGE}:i386-build${BUILD_NUMBER}
	docker tag ${DOCKER_USERNAME}/${IMAGE}:i386-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:i386
	docker push ${DOCKER_USERNAME}/${IMAGE}:i386
	@mkdir -p ${DOCKER_BUILD_FLAG}/${IMAGE}
	@touch $@

# ARMv7 32-bit architecture
${DOCKERFILES_DIR}/%/Dockerfile.arm32v7: ${DOCKERFILES_DIR}/%/template.Dockerfile
	gpp ${GPP_FLAGS} -D ARCH_ARM32V7 -o $@ $<

${DOCKER_BUILD_FLAG}/%/arm32v7: ${DOCKERFILES_DIR}/%/Dockerfile.arm32v7
	$(eval IMAGE := ${word 2,${subst /, ,$@}})
	docker build -t ${DOCKER_USERNAME}/${IMAGE}:arm32v7-build${BUILD_NUMBER} -f ${DOCKERFILES_DIR}/${IMAGE}/Dockerfile.arm32v7 ${DOCKERFILES_DIR}/${IMAGE}
	docker push ${DOCKER_USERNAME}/${IMAGE}:arm32v7-build${BUILD_NUMBER}
	docker tag ${DOCKER_USERNAME}/${IMAGE}:arm32v7-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:arm32v7
	docker push ${DOCKER_USERNAME}/${IMAGE}:arm32v7
	@mkdir -p ${DOCKER_BUILD_FLAG}/${IMAGE}
	@touch $@

# ARMv8 64-bbit architecture
${DOCKERFILES_DIR}/%/Dockerfile.arm64v8: ${DOCKERFILES_DIR}/%/template.Dockerfile
	gpp ${GPP_FLAGS} -D ARCH_ARM64V8 -o $@ $<

${DOCKER_BUILD_FLAG}/%/arm64v8: ${DOCKERFILES_DIR}/%/Dockerfile.arm64v8
	$(eval IMAGE := ${word 2,${subst /, ,$@}})
	docker build -t ${DOCKER_USERNAME}/${IMAGE}:arm64v8-build${BUILD_NUMBER} -f ${DOCKERFILES_DIR}/${IMAGE}/Dockerfile.arm64v8 ${DOCKERFILES_DIR}/${IMAGE}
	docker push ${DOCKER_USERNAME}/${IMAGE}:arm64v8-build${BUILD_NUMBER}
	docker tag ${DOCKER_USERNAME}/${IMAGE}:arm64v8-build${BUILD_NUMBER} ${DOCKER_USERNAME}/${IMAGE}:arm64v8
	docker push ${DOCKER_USERNAME}/${IMAGE}:arm64v8
	@mkdir -p ${DOCKER_BUILD_FLAG}/${IMAGE}
	@touch $@

all:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	$(eval IMAGES := $(subst ${DOCKERFILES_DIR}/,,$(wildcard ${DOCKERFILES_DIR}/*)))
	$(eval ARCHITECTURES := amd64 i386 arm32v7 arm64v8)

	${MAKE} $(foreach image,${IMAGES},$(foreach arch,${ARCHITECTURES},${DOCKER_BUILD_FLAG}/$(image)/$(arch)))
	
clean:
	rm -rf ${DOCKERFILES_DIR}/*/Dockerfile.{i386,amd64,arm32v7,arm64v8}
	@rm -rf ${DOCKER_BUILD_FLAG}