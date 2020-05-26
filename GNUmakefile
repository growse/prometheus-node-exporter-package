DEBNAME := prometheus-node-exporter
APP_REMOTE := github.com/prometheus/node_exporter
VERSION := v1.0.0
APPDESCRIPTION := Exporter for machine metrics
APPURL := https://github.com/prometheus/node_exporter
ARCH := amd64 arm
GO_BUILD_SOURCE := .

# Setup
BUILD_NUMBER ?= 0
DEBVERSION := $(VERSION:v%=%)-$(BUILD_NUMBER)
GOPATH := $(abspath gopath)
APPHOME := $(GOPATH)/src/$(APP_REMOTE)

# Let's map from go architectures to deb architectures, because they're not the same!
DEB_arm_ARCH := armhf
DEB_amd64_ARCH := amd64

# Version info for binaries
CGO_ENABLED := 0
GOARM := 7
VPREFIX := github.com/prometheus/common/version

# Can only expand these after the git checkout
GIT_REVISION = $(shell cd $(APPHOME) && git rev-parse --short HEAD)
GIT_BRANCH = $(shell cd $(APPHOME) && git rev-parse --abbrev-ref HEAD)
IMAGE_TAG = $(shell cd $(APPHOME) && git describe --exact-match 2> /dev/null)

GO_LDFLAGS = -s -w -X $(VPREFIX).Branch=$(GIT_BRANCH) -X $(VPREFIX).Version=$(IMAGE_TAG) -X $(VPREFIX).Revision=$(GIT_REVISION) -X $(VPREFIX).BuildUser=$(shell whoami)@$(shell hostname) -X $(VPREFIX).BuildDate=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
DYN_GO_FLAGS = -ldflags "$(GO_LDFLAGS)" -tags netgo -mod vendor

.EXPORT_ALL_VARIABLES:

.PHONY: package
package: $(addsuffix .deb, $(addprefix $(DEBNAME)_$(DEBVERSION)_, $(foreach a, $(ARCH), $(a))))

.PHONY: build
build: $(addprefix $(APPHOME)/dist/$(DEBNAME)_linux_, $(foreach a, $(ARCH), $(a)))

.PHONY: checkout
checkout: $(APPHOME)

$(GOPATH):
	mkdir $(GOPATH)

$(APPHOME): $(GOPATH)
	git clone https://$(APP_REMOTE) $(APPHOME)
	cd $(APPHOME) && git checkout $(VERSION)

$(APPHOME)/dist/$(DEBNAME)_linux_%: $(APPHOME)
	echo $(GIT_REVISION) && \
	echo $(IMAGE_TAG) && \
	cd $(APPHOME) && \
	GOOS=linux GOARCH=$* go build $(DYN_GO_FLAGS) -o dist/$(DEBNAME)_linux_$* $(GO_BUILD_SOURCE)

$(DEBNAME)_$(DEBVERSION)_%.deb: $(APPHOME)/dist/$(DEBNAME)_linux_%
	chmod +x $<
	bundle exec fpm -s dir -t deb -n $(DEBNAME) --description "$(APPDESCRIPTION)" --url $(APPURL) --deb-changelog $(APPHOME)/CHANGELOG.md --prefix / -a $(DEB_$*_ARCH) -v $(DEBVERSION) --deb-systemd prometheus-node-exporter.service --config-files /etc/default/prometheus-node-exporter prometheus-node-exporter.defaults=/etc/default/prometheus-node-exporter $<=/usr/sbin/node_exporter

.PHONY: clean
clean:
	rm -f *.deb
	rm -rf $(GOPATH)
