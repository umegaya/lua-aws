MOCK=

.PHONY: test
test:
	 find ./test -name "*.lua" | xargs -I {} ./test/tools/run.sh {} $(MOCK)