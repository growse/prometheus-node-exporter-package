DEBNAME := prometheus-node-exporter
APP_REMOTE := github.com/prometheus/node_exporter
# renovate: datasource=github-releases depName=prometheus/node_exporter
NODE_EXPORTER_VERSION := v1.10.0
APPDESCRIPTION := Exporter for machine metrics
APPURL := https://github.com/prometheus/node_exporter
ARCH := arm arm64 amd64
DEB_ARCH := armhf arm64 amd64
GO_BUILD_SOURCE := .

# Setup
BUILD_NUMBER ?= 0
DEBVERSION := $(NODE_EXPORTER_VERSION:v%=%)-$(BUILD_NUMBER)
GOPATH := $(abspath gopath)
APPHOME := $(GOPATH)/src/$(APP_REMOTE)

# Let's map from go architectures to deb architectures, because they're not the same!
GO_armhf_ARCH := arm
GO_arm64_ARCH := arm64
GO_amd64_ARCH := amd64

# Version info for binaries
CGO_ENABLED := 0
GOARM := 6
VPREFIX := github.com/prometheus/common/version

GO_LDFLAGS = -s -w -X $(VPREFIX).Branch=$(GIT_BRANCH) -X $(VPREFIX).Version=$(IMAGE_TAG) -X $(VPREFIX).Revision=$(GIT_REVISION) -X $(VPREFIX).BuildUser=$(shell whoami)@$(shell hostname) -X $(VPREFIX).BuildDate=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
DYN_GO_FLAGS = -ldflags "$(GO_LDFLAGS)" -tags netgo -mod=readonly

.EXPORT_ALL_VARIABLES:

.PHONY: package
package: $(addsuffix .deb, $(addprefix $(DEBNAME)_$(DEBVERSION)_, $(foreach a, $(DEB_ARCH), $(a))))



.PHONY: checkout
checkout: $(APPHOME)

$(GOPATH):
	mkdir $(GOPATH)

$(APPHOME): $(GOPATH)
	git clone --depth 1 --branch $(NODE_EXPORTER_VERSION) https://$(APP_REMOTE) $(APPHOME)
	cd $(APPHOME) && git checkout $(NODE_EXPORTER_VERSION)

$(APPHOME)/dist/$(DEBNAME)_linux_%: $(APPHOME)
	$(eval GIT_REVISION := $(shell cd $(APPHOME) && git rev-parse --short HEAD))
	$(eval GIT_BRANCH := $(shell cd $(APPHOME) && git rev-parse --abbrev-ref HEAD))
	$(eval IMAGE_TAG := $(shell cd $(APPHOME) && git describe --exact-match))
	cd $(APPHOME) && \
	GOOS=linux GOARCH=$(GO_$*_ARCH) go build $(DYN_GO_FLAGS) -o dist/$(DEBNAME)_linux_$* $(GO_BUILD_SOURCE)
	upx $@

$(DEBNAME)_$(DEBVERSION)_%.deb: $(APPHOME)/dist/$(DEBNAME)_linux_%
	bundle exec fpm -f \
	-s dir \
	-t deb \
	--license Apache \
	--deb-priority optional \
	--deb-systemd-enable \
	--deb-systemd-restart-after-upgrade \
	--deb-systemd-auto-start \
	--after-install=deb-scripts/after-install.sh \
	--after-upgrade=deb-scripts/after-install.sh \
	--after-remove=deb-scripts/after-remove.sh \
	--depends adduser,systemd \
	--maintainer github@growse.com \
	--vendor https://prometheus.io/ \
	-n $(DEBNAME) \
	--description "$(APPDESCRIPTION)" \
	--url $(APPURL) \
	--deb-changelog $(APPHOME)/CHANGELOG.md \
	--prefix / \
	-a $* \
	-v $(DEBVERSION) \
	--deb-systemd deb-scripts/prometheus-node-exporter.service \
	--deb-systemd-auto-start \
	--deb-systemd-enable \
	--deb-systemd-restart-after-upgrade \
	--config-files /etc/default/prometheus-node-exporter \
	deb-scripts/prometheus-node-exporter.socket=/lib/systemd/system/prometheus-node-exporter.socket \
	deb-scripts/prometheus-node-exporter.defaults=/etc/default/prometheus-node-exporter \
	$<=/usr/sbin/node_exporter

.PHONY: clean
clean:
	chmod -R +w gopath
	rm -f *.deb
	rm -rf $(GOPATH)
