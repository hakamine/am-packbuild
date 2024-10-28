NAME          = jhove
VERSION       ?= 1.32.0
RELEASE	      ?= 1~22.04
GIT_URL	      = https://github.com/openpreserve/jhove
DEB_TOPDIR    = "/debbuild"
DOCKER_VOLUME = "/src"
DOCKER_IMAGE  = "debbuild-$(NAME)-$(VERSION)"

.PHONY: build-docker-image build deb-build deb-clean deb-test update-changelog

all: build-docker-image build

build-docker-image:
	@echo "==> Building Docker image with build environment."
	@docker build --tag "$(DOCKER_IMAGE)" --build-arg GIT_URL="$(GIT_URL)" --build-arg GIT_BRANCH="v$(VERSION)" --build-arg PACKAGE="$(NAME)" .

build:
	@echo "==> Building deb."
	docker run \
                   -e RELEASE=$(RELEASE) \
                   --rm \
                   --volume "$(shell pwd):$(DOCKER_VOLUME)" \
                  $(DOCKER_IMAGE) \
                   make -C $(DOCKER_VOLUME) deb-build

deb-build: deb-clean
	@echo "==> Build package from source."
	cd /debbuild/$(NAME) && mvn package
	@echo "==> Copy package skel."
	cp -rf $(DOCKER_VOLUME)/package /debbuild/$(NAME)_$(VERSION)-$(RELEASE)
	sed -i 's/RELEASE/$(RELEASE)/g' /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/DEBIAN/control
	@echo "==> Build package."
	cp /debbuild/$(NAME)/jhove-apps/target/jhove-apps-*.jar  /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/jhove.jar
	cp /debbuild/$(NAME)/jhove-ext-modules/target/jhove-ext-modules-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/jhove-ext-modules.jar
	cp /debbuild/$(NAME)/jhove-core/target/jhove-core-*.jar  /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/jhove-core.jar
	cp /debbuild/$(NAME)/jhove-modules/pdf-hul/target/pdf-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/pdf-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/jpeg-hul/target/jpeg-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/jpeg-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/wave-hul/target/wave-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/wave-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/ascii-hul/target/ascii-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/ascii-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/jpeg2000-hul/target/jpeg2000-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/jpeg2000-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/utf8-hul/target/utf8-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/utf8-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/aiff-hul/target/aiff-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/aiff-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/xml-hul/target/xml-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/xml-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/html-hul/target/html-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/html-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/tiff-hul/target/tiff-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/tiff-hul.jar
	cp /debbuild/$(NAME)/jhove-modules/gif-hul/target/gif-hul-*.jar /debbuild/$(NAME)_$(VERSION)-$(RELEASE)/usr/share/java/gif-hul.jar
	dpkg-deb --build /debbuild/$(NAME)_$(VERSION)-$(RELEASE)
	@echo "==> Copying built  files."
	mkdir -p $(DOCKER_VOLUME)/build/
	cp  $(DEB_TOPDIR)/*.deb  $(DOCKER_VOLUME)/build/

deb-clean:
	@echo "==> Cleaning up previous RPMs builds."
	@rm -rf $(DOCKER_VOLUME)/build/

# TODO: Create repo and test it
deb-test:
	@docker run --rm --volume="$(shell pwd):$(DOCKER_VOLUME)" ubuntu:jammy echo "Create repo and install package"
