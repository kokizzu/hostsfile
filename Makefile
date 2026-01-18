.PHONY: test release

SHELL = /bin/bash -o pipefail

GOBIN := $(shell go env GOPATH)/bin
BUMP_VERSION := $(GOBIN)/bump_version
STATICCHECK := $(GOBIN)/staticcheck
RELEASE := $(GOBIN)/github-release
WRITE_MAILMAP := $(GOBIN)/write_mailmap

UNAME := $(shell uname)

test:
	go test ./...

$(STATICCHECK):
	go install honnef.co/go/tools/cmd/staticcheck@latest

$(BUMP_VERSION):
	go install github.com/kevinburke/bump_version@latest

$(RELEASE):
	go install github.com/aktau/github-release@latest

$(WRITE_MAILMAP):
	go install github.com/kevinburke/write_mailmap@latest

force: ;

AUTHORS.txt: force | $(WRITE_MAILMAP)
	$(WRITE_MAILMAP) > AUTHORS.txt

authors: AUTHORS.txt

lint: | $(STATICCHECK)
	$(STATICCHECK) ./...
	go vet ./...

race-test: lint
	go test -race ./...

# Run "GITHUB_TOKEN=my-token make release version=0.x.y" to release a new version.
release: race-test
	$(BUMP_VERSION) minor cmd.go
	git push origin --tags
