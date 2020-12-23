MOCK=
LUA=
IMAGE=umegaya/lua-aws-test
ECR_REPO=871570535967.dkr.ecr.ap-northeast-1.amazonaws.com
LAMBDA_IMAGE=$(ECR_REPO)/lua-aws-lambda-test

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

image_lambda_test:
	docker build ./test/tools/lambda -t $(LAMBDA_IMAGE)

push_lambda_image:
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(ECR_REPO)
	docker push $(LAMBDA_IMAGE)