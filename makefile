MOCK=
LUA=

.PHONY: test
test:
	find ./test -name "*.lua" | LUA=$(LUA) xargs -I {} ./test/tools/run.sh {} $(MOCK)

image:
	docker build ./test/tools -t umegaya/lua-aws-test

ci:
	docker run --rm -ti -v `pwd`:/project -w /project -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) -e EC2_URL=$(EC2_URL) umegaya/lua-aws-test bash -c "make test MOCK=$(MOCK) LUA=$(LUA)"

shell:
	docker run --rm -ti -v `pwd`:/project -w /project -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) -e EC2_URL=$(EC2_URL) umegaya/lua-aws-test bash	