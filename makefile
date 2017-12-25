.PHONY: test
test:
	 find ./test -name "*.lua" | xargs -I {} lj {}