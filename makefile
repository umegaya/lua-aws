MOCK=
LUA=
IMAGE=umegaya/lua-aws-test

.PHONY: test
test:
	docker run --init --rm -ti -v `pwd`:/project -w /project -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) -e EC2_URL=$(EC2_URL) umegaya/lua-aws-test-luajit bash -c "make runtest MOCK=$(MOCK) LUA=$(LUA)"

image:
	docker build ./test/tools -t umegaya/lua-aws-test

image_luajit:
	docker build ./test/tools -t umegaya/lua-aws-test-luajit -f ./test/tools/Dockerfile.luajit

ci:
	docker run --init --rm -ti -v `pwd`:/project -w /project -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) -e EC2_URL=$(EC2_URL) umegaya/lua-aws-test bash -c "make runtest MOCK=$(MOCK) LUA=$(LUA)"

shell:
	docker run --rm -ti -v `pwd`:/project -w /project -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) -e EC2_URL=$(EC2_URL) $(IMAGE) bash

runtest:
	find ./test -name "*.lua" | LUA=$(LUA) xargs -I {} ./test/tools/run.sh {} $(MOCK)
