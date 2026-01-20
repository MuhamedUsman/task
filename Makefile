# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## db/migration/new: create migration files with specified filename
.PHONY: db/migration/new
db/migration/new:
	@read  -p "Input file name: " filename; \
	migrate create -seq -ext .sql -dir ./migrations $$filename

## db/migration/apply: apply the migration with the [ up | down | goto # | force # ] as specified
.PHONY: db/migration/apply
db/migration/apply:
	@read -p "Input apply params: " apply_params; \
	migrate -path ./migrations -database sqlite3://task.db $$apply_params

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit:
	@echo 'Formating code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	CGO_ENABLED=1 go test -race -vet=off ./...

# ==================================================================================== #
# BUILD
# ==================================================================================== #

current_time = $(shell date --iso-8601=seconds)
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -w -X main.buildTime=${current_time} -X main.version=${git_description}'

## build/task: build the task CLI binary with compression using LZMA
.PHONY: build/letschat
build/letschat:
	mkdir -p bin && \
 	CGO_ENABLED=1 go build -ldflags="-s -w -extldflags='-static'" -trimpath -o bin/letschat.exe ./cmd/letschat && \
 	upx --best --lzma bin/letschat.exe