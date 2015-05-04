local sha2 = require 'lua-aws.deps.sha2'
local vectors = {
	[""] 							= "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", 
	["a"] 							= "CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB", 
	["abc"]							= "BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD", 
	["message digest"]				= "F7846F55CF23E14EEBEAB5B4E1550CAD5B509E3348FBC4EFA3A1413D393CB650",
	["abcdefghijklmnopqrstuvwxyz"] 	= "71C480DF93D6AE2F1EFAD1447C66C9525E316218CF51FC8D9ED832F2DAF18B73",
	["abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"]
									= "248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1",
	["A...Za...z0...9"]				= "E1904B6EFF23EB8D0D251254C8E71D9E3B3C6822A1C3F64427E9CE09933985EA", 
		-- https://www.cosic.esat.kuleuven.be/nessie/testvectors/hash/sha/Sha-2-256.unverified.test-vectors says digest is
		-- "DB4BFCBD4DA0CD85A60C3C37D3FBD8805C77F15FC6B1FDFE614EE0A7C8FDB4C0", but various implementation says digest is above.
	[("1234567890"):rep(8)]			= "F371BC4A311F2B009EEF952DD83CA80E2B60026C8E935592D0F9C308453C813E",
	[("a"):rep(1000 * 1000)]		= "CDC76E5C9914FB9281A1C7E284D73E67F1809A48A497200E046D39CCC7112CD0",
}

--[[
local unmatches = {}
for message, hash in pairs(vectors) do
	local tag = message:sub(1,16)
	if #message > #tag then
		tag = (tag .. "...")
	end
	local h = sha2.hash256(message):upper()
	if h ~= hash then
		table.insert(unmatches, {tag, h, hash})
	end
end
if #unmatches > 0 then
	for _,um in ipairs(unmatches) do
		print("unmatch ["..um[1].."] hash=["..um[2].."] should be ["..um[3].."]")
	end
	assert(false)
end
]]


local h = sha2.hash256("POST\nsqs.ap-northeast-1.amazonaws.com\n/\nAWSAccessKeyId=AKIAI3AZWYC2NG6LU2EQ&Action=SendMessage&MessageBody=%7B%22email_id%22%3A2%2C%22contact_id%22%3A%221-xxxxx%40hotmail.es%22%2C%22bulk_id%22%3A1%2C%22email_version_id%22%3A14%2C%22client_id%22%3A1%7D&QueueUrl=http%3A%2F%2Fsqs.ap-northeast-1.amazonaws.com%2F871570535967%2FtestQueue&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2014-10-16T20%3A21%3A59%2B0900&Version=2012-11-05");
assert(h == "570e036eefb1d926c544dcdc2ae37b23a785f1254d1797b5f208cae388369992", "wrong hash:"..h)
