REGISTRY = aditya005

LATEST_COMMIT_SHORT := $(shell git rev-parse --short HEAD^{commit})
GIT_REF ?= $(LATEST_COMMIT_SHORT)
TAG := $(shell git rev-parse --short $(GIT_REF)^{commit})

IMAGE_BASE = $(REGISTRY)/base
IMAGE_BASE_COMMIT = $(REGISTRY)/base:$(LATEST_COMMIT_SHORT)

CHROMEDRIVER_BASE = $(REGISTRY)/chromedriver
CHROMEDRIVER_BASE_COMMIT = $(REGISTRY)/chromedriver:$(LATEST_COMMIT_SHORT)

ifeq ($(TAG),)
$(error git cannot find a commit for "$(GIT_REF)")
endif

#################
# Global Targets
#################
.PHONY: all
all: build

.PHONY: pull
pull: pull-base pull-chromedriver

.PHONY: build
build: build-base build-chromedriver

.PHONY: push
push: push-base push-chromedriver

# Pull targets
pull-base:
	docker pull $(IMAGE_BASE):$(TAG)

pull-chromedriver:
	docker pull $(CHROMEDRIVER_BASE):$(TAG)


# Build targets
build-base: 
	docker build --target base --rm \
		--tag $(IMAGE_BASE) \
		--tag $(IMAGE_BASE_COMMIT) \
		base

build-chromedriver: 
	docker build --target chromedriver --rm \
		--tag $(CHROMEDRIVER_BASE) \
		--tag $(CHROMEDRIVER_BASE_COMMIT) \
		base

# Push targets
push-base: git-check
	docker push $(IMAGE_BASE_COMMIT)
	docker push $(IMAGE_BASE)

push-chromedriver: git-check
	docker push $(CHROMEDRIVER_BASE_COMMIT)
	docker push $(CHROMEDRIVER_BASE)

##################
# Sanity Git check
##################

.PHONY: git-check
.NOTPARALLEL: git-check
git-check:
	@git diff
	@git diff-index --quiet HEAD || \
		(git status --long -unormal \
			&& echo '\nERROR: Commit existing changes, then try again.' \
			&& exit 1)



############
# Tag Commit
############

.PHONY: git-tag
git-tag: COMMIT_DATE_RFC := $(shell git show -s --date=rfc --format=%cd $(TAG))
git-tag: COMMIT_DATE_SHORT := $(shell git show -s --date=short --format=%cd $(TAG))
git-tag: $(PULL)
	echo $(COMMIT_DATE_RFC) > GIT_TAG_MSG
	echo >> GIT_TAG_MSG
	echo Docker Images: >> GIT_TAG_MSG
	echo $(IMAGE_BMP):$(TAG) >> GIT_TAG_MSG
	echo $(IMAGE_BASE):$(TAG) >> GIT_TAG_MSG
	echo >> GIT_TAG_MSG
	echo Application Versions: >> GIT_TAG_MSG

.PHONY: print-phony
print-phony:

print-%: print-phony
	@echo $($*)