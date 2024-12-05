NAME          = verapdf
VERSION       = 1.26.2
RPM_TOPDIR    = "/rpmbuild"
DOCKER_VOLUME = "/src"
DOCKER_IMAGE  = "rpmbuild-$(NAME)-$(VERSION)"

RPMBUILD_ARGS := \
	--define "_topdir $(RPM_TOPDIR)" \
	--define "_etcdir $(DOCKER_VOLUME)/etc" \
	--define "name $(NAME)" \
	--define "version $(VERSION)"

.PHONY: build-docker-image build rpm-build rpm-clean rpm-test

all: build-docker-image build

build-docker-image:
	@echo "==> Building Docker image with build environment."
	@docker build --tag "$(DOCKER_IMAGE)" .

build:
	@echo "==> Building RPM."
	@docker run --rm --volume "$(shell pwd):$(DOCKER_VOLUME)" $(DOCKER_IMAGE) make -C $(DOCKER_VOLUME) rpm-build

dev:
	@echo "==> Building RPM."
	@docker run -i -t --rm --volume "$(shell pwd):$(DOCKER_VOLUME)" $(DOCKER_IMAGE) /bin/bash


rpm-build: rpm-clean
	@echo "==> Preparing environment for rpmbuild."
	mkdir -p $(RPM_TOPDIR)
	cp $(DOCKER_VOLUME)/package.spec $(RPM_TOPDIR)/package.spec
	mkdir -p $(RPM_TOPDIR)/BUILD/
	cp files/* $(RPM_TOPDIR)/BUILD/
	cd $(RPM_TOPDIR)/; rpmbuild $(RPMBUILD_ARGS) -ba --clean package.spec

	@echo "==> Copying RPM files."
	cp -p $(RPM_TOPDIR)/RPMS/x86_64/$(NAME)-$(VERSION)*.x86_64.rpm $(DOCKER_VOLUME)
	cp -p $(RPM_TOPDIR)/SRPMS/$(NAME)-$(VERSION)*.src.rpm $(DOCKER_VOLUME)

rpm-clean:
	@echo "==> Cleaning up previous RPMs builds."
	@rm -rf $(RPM_TOPDIR)

rpm-test:
	@docker run --rm --volume="$(shell pwd):$(DOCKER_VOLUME)" rockylinux:9 bash -c "yum install -y epel-release && yum localinstall -y --nogpgcheck $(DOCKER_VOLUME)/$(NAME)-$(VERSION)*.rpm"

cleanup:
	@echo "==> Remove artifacts created as root."
	@docker run -i  \
		--rm \
		--volume "$(shell pwd):$(DOCKER_VOLUME)" \
		$(DOCKER_IMAGE) \
		bash -c "rm -rf /src/*.rpm /src/verapdf"
