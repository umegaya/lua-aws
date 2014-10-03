local class = require('lua-aws.class')
local util = require('lua-aws.util')

local AWS = class.AWS {
	VERSION = 'v0.1.0',
	initialize = function (self, config, http_engine)
		assert(config and config.accessKeyId and config.secretAccessKey)
		self._config = config
		self._http_engine = http_engine or util.luasocket_http_engine or util.curl_http_engine
		--> define service
		self.DynamoDB = require('lua-aws.services.dynamodb').new(self)
		self.EC2 = require('lua-aws.services.ec2').new(self)
    self.SQS = require('lua-aws.services.sqs').new(self)

		--[[
		require('./services/autoscaling')
		require('./services/cloudformation')
		require('./services/cloudfront')
		require('./services/cloudsearch')
		require('./services/cloudwatch')
		require('./services/datapipeline')
		require('./services/directconnect')
		require('./services/elasticache')
		require('./services/elasticbeanstalk')
		require('./services/elastictranscoder')
		require('./services/elb')
		require('./services/emr')
		require('./services/glacier')
		require('./services/iam')
		require('./services/importexport')
		require('./services/opsworks')
		require('./services/rds')
		require('./services/redshift')
		require('./services/route53')
		require('./services/s3')
		require('./services/ses')
		require('./services/simpledb')
		require('./services/simpleworkflow')
		require('./services/sns')
		require('./services/sqs')
		require('./services/storagegateway')
		require('./services/sts')
		require('./services/support')
		]]--	
	end,
	config = function (self)
		return self._config
	end,
	api_log = function (self, api, ...)
		print(api:endpoint_prefix() .. ':v[' .. api:version() .. ']:', ...)
	end,
	http_request = function (self, req)
		return self._http_engine(req)
	end,
}
--[[
require('./sequential_executor');
require('./event_listeners');
require('./signers/request_signer');
require('./param_validator');
require('./metadata_service');
]]--
return AWS
