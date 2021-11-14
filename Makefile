
v_compiler = $(shell which v)

all: format test

test:
	@echo "Running tests..."
	$(v_compiler) test .

format:
	$(v_compiler) fmt -w .