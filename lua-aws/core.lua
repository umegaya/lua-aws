local class = require('lua-aws.class')
local util = require('lua-aws.util')
local available_engines = require 'lua-aws.engines.available'
assert(available_engines)

local AWS = class.AWS {
	VERSION = 'v0.1.0',
	initialize = function (self, config, http_engine)
		assert(config and config.accessKeyId and config.secretAccessKey)
		self._config = config
		if http_engine then -- backward conpatibility
			if config.preferred_engines then
				config.preferred_engines = {}
			end
			config.preferred_engines.http = http_engine
		end
		local engines = self:init_engines(config.preferred_engines or {})
		self._http_engine = engines.http
		self._json_engine = engines.json
		self._fs_engine = engines.fs
		--self._http_engine = http_engine or self:get_http_engine()
		--> define service
		self.DynamoDB = require('lua-aws.services.dynamodb').new(self)
		self.EC2 = require('lua-aws.services.ec2').new(self)
	    self.Kinesis = require('lua-aws.services.kinesis').new(self)
	    self.SNS = require('lua-aws.services.sns').new(self)
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
	init_engines = function (self, preferred)
		local ok, r 
		local selected_engines = {}
		for k,v in pairs(available_engines) do
			if preferred[k] then
				local t = type(preferred[k])
				if t == 'string' then
					selected_engines[k] = self:try_load_engines(k, preferred[k])
					if preferred.strict then
						assert(selected_engines[k], "application require "..preferred[k].." for "..k.." strictly but cannot")
					end
				else
					selected_engines[k] = preferred[k]
				end
			end
			if not selected_engines[k] then
				for i=1,#v do
					if (not preferred[k]) or (v[i] ~= preferred[k]) then
						selected_engines[k] = self:try_load_engines(k, v[i])
						if selected_engines[k] then
							break
						end	
					end
				end
			end
			assert(selected_engines[k], "no engine for "..k.." available")
		end
		return selected_engines
	end,
	try_load_engines = function (self, engine_type, engine_name)
		ok, r = pcall(require, 'lua-aws.engines.'..engine_type..'.'..engine_name)
		return ok and r
	end,
	fs = function (self)
		return self._fs_engine
	end,
	json = function (self)
		return self._json_engine
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
