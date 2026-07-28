.PHONY: all build run test clean lint format check release deploy

DART_CMD ?= dart

all: build

check: build lint test

build:
	$(DART_CMD) pub get
	$(DART_CMD) compile exe bin/server.dart -o build/bin/server

run:
	$(DART_CMD) run bin/server.dart

test:
	$(DART_CMD) test

lint:
	$(DART_CMD) analyze

format:
	$(DART_CMD) format .

clean:
	rm -rf build/ .dart_tool/

release: build run

deploy:
	gcloud builds submit . --config cloudbuild.yaml
