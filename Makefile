# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: bpi android ios bpi-cross evm all test clean
.PHONY: bpi-linux bpi-linux-386 bpi-linux-amd64 bpi-linux-mips64 bpi-linux-mips64le
.PHONY: bpi-linux-arm bpi-linux-arm-5 bpi-linux-arm-6 bpi-linux-arm-7 bpi-linux-arm64
.PHONY: bpi-darwin bpi-darwin-386 bpi-darwin-amd64
.PHONY: bpi-windows bpi-windows-386 bpi-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

bpi:
	$(GORUN) build/ci.go install ./cmd/bpi
	@echo "Done building."
	@echo "Run \"$(GOBIN)/bpi\" to launch bpi."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/bpi.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/bpi.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	env GO111MODULE=on go clean -cache
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

bpi-cross: bpi-linux bpi-darwin bpi-windows bpi-android bpi-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/bpi-*

bpi-linux: bpi-linux-386 bpi-linux-amd64 bpi-linux-arm bpi-linux-mips64 bpi-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-*

bpi-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/bpi
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep 386

bpi-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/bpi
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep amd64

bpi-linux-arm: bpi-linux-arm-5 bpi-linux-arm-6 bpi-linux-arm-7 bpi-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep arm

bpi-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/bpi
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep arm-5

bpi-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/bpi
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep arm-6

bpi-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/bpi
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep arm-7

bpi-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/bpi
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep arm64

bpi-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/bpi
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep mips

bpi-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/bpi
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep mipsle

bpi-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/bpi
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep mips64

bpi-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/bpi
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/bpi-linux-* | grep mips64le

bpi-darwin: bpi-darwin-386 bpi-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/bpi-darwin-*

bpi-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/bpi
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-darwin-* | grep 386

bpi-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/bpi
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-darwin-* | grep amd64

bpi-windows: bpi-windows-386 bpi-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/bpi-windows-*

bpi-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/bpi
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-windows-* | grep 386

bpi-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/bpi
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/bpi-windows-* | grep amd64
