PACKAGE ?= archivematica
BRANCH ?= qa/1.x
VERSION ?= 1.17.0
RELEASE ?= 1
RPM_TOPDIR = "/rpmbuild"
DOCKER_VOLUME = "/src"
DOCKER_IMAGE ?= $(subst ~,-,"rpmbuild-$(PACKAGE)-$(VERSION)")

GIT_REPO ?= "https://github.com/artefactual/archivematica"

CHANGELOG_DATE = $(shell date "+%a %b %d %Y")
PACKBUILD_HEAD   ?= $(shell git rev-parse HEAD )
PACKAGE_HEAD   ?= $(shell git ls-remote $(GIT_REPO) refs/heads/$(BRANCH) | awk '{print $$1}' )


RPMBUILD_ARGS := \
	--define "_topdir $(RPM_TOPDIR)" \
	--define "_etcdir $(DOCKER_VOLUME)/etc" \
	--define "_branch $(BRANCH)" \
	--define "name $(PACKAGE)" \
	--define "rpmversion $(VERSION)" \
	--define "rpmrelease $(RELEASE)" \
	--define "branch $(BRANCH)" \
	--define "git_repo $(GIT_REPO)"

.PHONY: build-docker-image build rpm-build rpm-clean rpm-test

all: build-docker-image build

build-docker-image:
	@echo "==> Building Docker image with build environment."
	@docker build --tag "$(DOCKER_IMAGE)" .

build:
	@echo "==> Building RPM."
	@docker run \
		-e RPM_TOPDIR="$(RPM_TOPDIR)" \
		-e DOCKER_VOLUME="$(DOCKER_VOLUME)/etc" \
		-e PACKAGE="$(PACKAGE)" \
		-e VERSION="$(VERSION)" \
		-e RELEASE="$(RELEASE)" \
		-e BRANCH="$(BRANCH)" \
		-e GIT_REPO="$(GIT_REPO)" \
		-e PACKBUILD_HEAD="$(PACKBUILD_HEAD)" \
		-e PACKAGE_HEAD="$(PACKAGE_HEAD)" \
		--rm --volume "$(shell pwd):$(DOCKER_VOLUME)" $(DOCKER_IMAGE) make -C $(DOCKER_VOLUME) rpm-build

dev:
	@echo "==> Building RPM."
	@docker run -i -t \
		-e RPM_TOPDIR="$(RPM_TOPDIR)" \
		-e DOCKER_VOLUME="$(DOCKER_VOLUME)/etc" \
		-e PACKAGE="$(PACKAGE)" \
		-e VERSION="$(VERSION)" \
		-e RELEASE="$(RELEASE)" \
		-e BRANCH="$(BRANCH)" \
		-e PACKBUILD_HEAD="$(PACKBUILD_HEAD)" \
		-e PACKAGE_HEAD="$(PACKAGE_HEAD)" \
		--rm --volume "$(shell pwd):$(DOCKER_VOLUME)" $(DOCKER_IMAGE) /bin/bash

cleanup:
	@echo "==> Remove artifacts created as root."
	@docker run -i  \
		--rm \
		--volume "$(shell pwd):$(DOCKER_VOLUME)" \
		 $(DOCKER_IMAGE) \
		bash -c "rm -rf /src/*.rpm"


rpm-build: rpm-clean
	@echo "==> Preparing environment for rpmbuild."
	# Create needed folders and put files inplace
	mkdir -p $(RPM_TOPDIR)
	cp $(DOCKER_VOLUME)/$(PACKAGE).spec $(RPM_TOPDIR)/package.spec
	# Install dependencies
	yum-builddep -y $(RPM_TOPDIR)/package.spec
	# Update changelog
	sed -i '2s/^/* $(CHANGELOG_DATE) Artefactual <sysadmin@artefactual.com> - $(VERSION)-$(RELEASE) \n- Packbuild: $(PACKBUILD_HEAD)\n- Archivematica: $(PACKAGE_HEAD)\n/' $(DOCKER_VOLUME)/changelog
	cat $(DOCKER_VOLUME)/changelog >> $(RPM_TOPDIR)/package.spec

	rpmbuild $(RPMBUILD_ARGS) -ba --clean $(RPM_TOPDIR)/package.spec

	@echo "==> Copying RPM files."
	cp -p $(RPM_TOPDIR)/RPMS/x86_64/$(PACKAGE)-*.x86_64.rpm $(DOCKER_VOLUME)
	cp -p $(RPM_TOPDIR)/SRPMS/$(PACKAGE)-*.src.rpm $(DOCKER_VOLUME)

rpm-clean:
	@echo "==> Cleaning up previous builds."
	@rm -rf $(RPM_TOPDIR)

rpm-test:
	@docker run --rm --volume="$(shell pwd):$(DOCKER_VOLUME)" rockylinux:9 bash -c "yum install -y epel-release && yum localinstall -y --nogpgcheck $(DOCKER_VOLUME)/$(PACKAGE)-$(VERSION)*.rpm"
