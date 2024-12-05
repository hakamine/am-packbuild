NAME          = archivematica-storage-service
BRANCH        ?= qa/0.x
VERSION       ?= 0.23.0
RELEASE       ?= 1
RPM_TOPDIR    = "/rpmbuild"
DOCKER_VOLUME = "/src"
DOCKER_IMAGE  = $(subst ~,-,"rpmbuild-$(NAME)-$(VERSION)")

CHANGELOG_DATE = $(shell date "+%a %b %d %Y")
PACKBUILD_HEAD   ?= $(shell git rev-parse HEAD )

GIT_REPO ?= "https://github.com/artefactual/archivematica-storage-service"
PACKAGE_HEAD   ?= $(shell git ls-remote $(GIT_REPO) refs/heads/$(BRANCH) | awk '{print $$1}' )


RPMBUILD_ARGS := \
	--define "_topdir $(RPM_TOPDIR)" \
	--define "_etcdir $(DOCKER_VOLUME)/etc" \
	--define "_branch $(BRANCH)" \
	--define "name $(NAME)" \
	--define "git_repo $(GIT_REPO)" \
	--define "rpmversion $(VERSION)" \
	--define "rpmrelease $(RELEASE)"

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
                -e PACKAGE="$(NAME)" \
                -e VERSION="$(VERSION)" \
                -e RELEASE="$(RELEASE)" \
                -e BRANCH="$(BRANCH)" \
		-e GIT_REPO="$(GIT_REPO)" \
                -e PACKBUILD_HEAD="$(PACKBUILD_HEAD)" \
                -e PACKAGE_HEAD="$(PACKAGE_HEAD)" \
		--rm --volume "$(shell pwd):/$(DOCKER_VOLUME)" $(DOCKER_IMAGE) make -C /src rpm-build

rpm-build: rpm-clean
	@echo "==> Preparing environment for rpmbuild."
	mkdir -p $(RPM_TOPDIR)
	cp $(DOCKER_VOLUME)/package.spec $(RPM_TOPDIR)/package.spec
	yum-builddep -y $(RPM_TOPDIR)/package.spec
	# Populate ChangeLog
	sed -i '2s/^/* $(CHANGELOG_DATE) Artefactual <sysadmin@artefactual.com> - $(VERSION)-$(RELEASE) \n- Packbuild: $(PACKBUILD_HEAD)\n- Storage Service: $(PACKAGE_HEAD)\n/' $(DOCKER_VOLUME)/changelog
	cat $(DOCKER_VOLUME)/changelog >> $(RPM_TOPDIR)/package.spec

	rpmbuild $(RPMBUILD_ARGS) -ba --clean $(RPM_TOPDIR)/package.spec

	@echo "==> Copying RPM files."
	cp -p $(RPM_TOPDIR)/RPMS/x86_64/$(NAME)-$(VERSION)*.x86_64.rpm $(DOCKER_VOLUME)
	cp -p $(RPM_TOPDIR)/SRPMS/$(NAME)-$(VERSION)*.src.rpm $(DOCKER_VOLUME)

rpm-clean:
	@echo "==> Cleaning up previous RPMs builds."
	@rm -rf $(RPM_TOPDIR)

cleanup:
	@echo "==> Remove artifacts created as root."
	@docker run -i  \
		--rm \
		--volume "$(shell pwd):$(DOCKER_VOLUME)" \
		$(DOCKER_IMAGE) \
		bash -c "rm -rf /src/*.rpm"

rpm-test:
	@docker run --rm --volume="$(shell pwd):$(DOCKER_VOLUME)" rockylinux:9 bash -c "yum install -y epel-release && yum localinstall -y --nogpgcheck $(DOCKER_VOLUME)/$(NAME)-$(VERSION)*.rpm"
