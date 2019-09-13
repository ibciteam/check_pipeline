# Build Environment Variables
DEFAULT_REGISTRY :=infobloxcto
REGISTRY         ?=$(DEFAULT_REGISTRY)
REPOSITORY_PATH  := github.com/Infoblox-CTO/atlas.onprem.config.generator

# Docker Build variables
DOCKER_BUILDER := infoblox/buildtool:latest
BECOME         := sudo -E
DOCKER_RUNNER  =  docker run --rm -v $(CURDIR):/go/src/$(REPOSITORY_PATH) -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) -e CSP_HOST -e CSP_USER -e CSP_PASS
DOCKER_RUNNER  += $(DOCKER_ENVS) -w /go/src/$(REPOSITORY_PATH)
BUILDER        = $(DOCKER_RUNNER) $(DOCKER_BUILDER)

# jenkins build number
BUILD_NUMBER ?= 0

# Image
IMAGE_NAME             := ngp.onprem.config.generator
GIT_COMMIT             := $(shell git describe --tags --dirty=-unsupported --always || echo pre-commit)
IMAGE_VERSION          ?= $(GIT_COMMIT)-j$(BUILD_NUMBER)
DOCKER_GENERATOR_IMAGE := $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_VERSION)

.DEFAULT_GOAL := binary

CHART           := config-generator
CHART_VERSION   := $(IMAGE_VERSION)
CHART_FILE      := $(CHART)-$(CHART_VERSION).tgz
HELM_REPO_NAME  := deployment-configurations
HELM_REPO_PATH  := ../$(HELM_REPO_NAME)
HELM_IMAGE      ?= infoblox/helm:2.14.3-1

ENV ?= env-1
LIFECYCLE ?= integration
NAMESPACE ?= ngp-cp
APP_NAME ?= config-generator

#
# Protocol Compiler options
#
PROTOC = protoc -I 
.PHONY: proto
proto: 
	$(BECOME) $(PROTOC) proto/message proto/message/config.proto  --go_out=plugins=grpc:proto/message

# Target All
.PHONY: all
all: docker

# Target Docker
.PHONY: docker
docker: binary test docker-build docker-publish

# Target Binary
.PHONY: binary
binary: generator/generator

# Source Files
gofiles = $(shell find $1 -not -path '*/*_test.go' -type f -name "*.go")

# This variable holds the command to retrieve the Go files of this
# project. It is very convenient to use it then to validate the style
# errors and perform static validation.
SEARCH_GOFILES = find -not -path '*/vendor/*' -not -path '*/sample/*'  -type f -name "*.go"

# Validate the code style and formatting to match the accepted style of the
# open source Go projects. If the changes do not comply with validations the
# build will be failed.
.PHONY: check
check:
	$(BECOME) $(BUILDER) sh -xc '\
		test -z "`$(SEARCH_GOFILES) -exec gofmt -s -l {} \;`" \
		&& test -z "`$(SEARCH_GOFILES) -exec golint {} \;`"'

# Format the existing code in accordance with the gofmt.
.PHONY: fmt
fmt:
	$(BECOME) $(BUILDER) $(SEARCH_GOFILES) -exec gofmt -s -w {} \;

# Define list of packages to be tested.
TESTABLE := \
	$(REPOSITORY_PATH)/generator

.PHONY: test
test: unit integration

JUNIT_REPORT :=report.xml
TEST_UNIT_LOG :=test_unit.log
TEST_INT_LOG :=test_int.log
.PHONY: test-report
test-report: test
#	$(BECOME) $(BUILDER) sh -c 'cat $(TEST_UNIT_LOG) $(TEST_INT_LOG) 2>/dev/null | go-junit-report > $(JUNIT_REPORT)'
	$(BECOME) $(BUILDER) go test $(GOFLAGS) --cover $(REPOSITORY_PATH)/generator/...

.PHONY: unit
unit:
	$(BECOME) $(BUILDER) go test $(GOFLAGS) --cover $(REPOSITORY_PATH)/generator/...

.PHONY: integration
# No integration tests for now.
integration:

# Define set of files of the Controller component. A target using the set will
# rebuild only when one or several of these files change.
GENERATOR_DEPS  = $(call gofiles,generator)

# Build the Controller component.
 generator/generator: $(GENERATOR_DEPS) check
	$(BECOME) $(BUILDER) go build $(GOFLAGS) -o $@ ./$(@D)


.PHONY: vendor
vendor:
	@export GO111MODULE=on; go mod tidy; go mod vendor

# Remove build artifacts of the default goal.
.PHONY: clean
clean:
	$(BECOME) $(RM) -r bin/generator
	$(BECOME) $(RM) *.log report.xml

# Build an image from the artifact of the default goal. Keep in cache.
.PHONY: docker-build
docker-build: binary
	$(BECOME) docker build -t $(DOCKER_GENERATOR_IMAGE) generator

# Upload the image stored in cache to specified registry. Remove the image from
# cache.
.PHONY: docker-publish
docker-publish: docker-build
	$(BECOME) docker push $(DOCKER_GENERATOR_IMAGE)
	$(BECOME) docker rmi -f $(DOCKER_GENERATOR_IMAGE)

.PHONY: docker-publish-latest
docker-publish-latest: docker-build
	$(BECOME) docker tag $(DOCKER_GENERATOR_IMAGE) $(REGISTRY)/$(IMAGE_NAME):latest
	$(BECOME) docker push $(REGISTRY)/$(IMAGE_NAME):latest

# For Jenkins automated build (see https://github.com/Infoblox-CTO/janus-app-deployment/tree/master/jenkins)
.PHONY: build
build: binary

.PHONY: image-build
image-build: docker-build

.PHONY: image-push
image-push: docker-publish

.PHONY: show-image-version
show-image-version:
	@echo $(IMAGE_VERSION)

.PHONY: show-image-name
show-image-name:
	@echo $(IMAGE_NAME)

# This empty target was added for compatibility with build script in jenkins jobs
.PHONY: bootstrap
bootstrap: ;

yaml:
	helm template --name atlas --namespace $(NAMESPACE) \
		`$(HELM_REPO_PATH)/scripts/helm_args $(ENV) $(APP_NAME) --lifecycle $(LIFECYCLE)` repo/$(CHART_FILE)

.helm-lint:
	@cd repo && helm lint --set env=" " --set host.grpcCsp.domain=" " --set aws.s3apiBucket=" " --set host.csp.domain=" " --set host.registry.domain=" " $(CHART)

.helm-test: .helm-lint build-helm-package yaml
	rm repo/$(CHART_FILE)

.PHONY: build-helm-package
build-helm-package:
	cd repo && helm package $(CHART) --version $(CHART_VERSION)

build.properties:
	sed 's/{CHART_FILE}/$(CHART_FILE)/g' build/build.properties.in > build/build.properties

.PHONY: push-chart
push-chart: AWS_ACCESS_KEY_ID?=`aws configure get aws_access_key_id`
push-chart: AWS_SECRET_ACCESS_KEY?=`aws configure get aws_secret_access_key`
push-chart: AWS_REGION?=`aws configure get region`
push-chart: .helm-lint build-helm-package build.properties
	docker run -e AWS_REGION=${AWS_REGION} \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-v $(PWD)/repo:/pkg \
		${HELM_IMAGE} s3 push /pkg/$(CHART_FILE) infobloxcto
