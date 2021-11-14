
v_compiler = $(shell which v)

all: format test

test:
	@echo "Running tests..."
	$(v_compiler) -g test .

fmt:
	$(v_compiler) fmt -w .

clean:
	$(RM) *.xml *.txt