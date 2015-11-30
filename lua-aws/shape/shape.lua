local class = require('lua-aws.class')
local util = require('lua-aws.util')

local Shape 
Shape = class.Shape {
    initialize = function (self, shape, options, member_name)
        options = options or {}

        self.shape = shape.shape
        self.api = options.api -- should not processed by pair()
        self.type = shape.type
        local ok, r = pcall(function () return self.location end)
        self.location = shape.location or self:tryGetValue("location") or 'body';
        self.name = self.name or shape.xmlName or shape.queryName or shape.locationName or member_name
        self.isStreaming = shape.streaming or self:tryGetValue("isStreaming") or false
        self.isComposite = shape.isComposite or false
        self.isShape = true -- should not processed by pair()
        self.isQueryName = shape.queryName and true or false -- should not processed by pair()
        self.isLocationName = shape.locationName and true or false -- should not processed by pair()

        if options.documentation then
          self.documentation = shape.documentation
          self.documentationUrl = shape.documentationUrl
        end

        self.isXmlAttribute = shape.xmlAttribute or false
        self.defaultValue = false
    end,
    tryGetValue = function (self, k)
        local ok, r = pcall(function () return self[k] end)
        return ok and r
    end,
    -- type conversion and parsing
    toWireFormat = function (self, value)
        return value or ''
    end,
    toType = function (self, value)
        return tostring(value)
    end,
    resolve = function (shape, options) 
        if shape.shape then
            local refShape = options.api:resolve_shape(shape.shape);
            if not refShape then
                error('Cannot find shape reference: ' .. shape.shape);
            end
            return refShape;
        end
        -- retuns nil
    end,

    create = function (shape, options, member_name)
        if shape.isShape then
            return shape;
        end

        local refShape = Shape.resolve(shape, options);
        if refShape then
            local filteredKeys = {}
            for k,v in pairs(shape) do
                if (not options.documentation) or (not k:match('documentation')) then
                    table.insert(filteredKeys, k)
                end
            end
            if (#filteredKeys == 1) and (filteredKeys[1] == 'shape') then -- no inline customizations
              return refShape
            end
            assert(false, "test: actually it used?")
            -- create an inline shape with extra members
            return class[os.tmpname()].extends(Shape).new(shape, options, member_name)
        else
            -- set type if not set
            if not shape.type then
                if shape.members then shape.type = 'structure'
                elseif shape.member then shape.type = 'list'
                elseif shape.key then shape.type = 'map'
                else shape.type = 'string' end
            end

            -- normalize types
            local origType = shape.type;
            if Shape.normalizedTypes[shape.type] then
                shape.type = Shape.normalizedTypes[shape.type];
            end

            if Shape.types[shape.type] then
                return Shape.types[shape.type].new(shape, options, member_name);
            else
                error('Unrecognized shape type: ' .. origType);
            end
        end
    end,
    normalizedTypes = {
        character = 'string',
        double = 'float',
        long = 'integer',
        short = 'integer',
        biginteger = 'integer',
        bigdecimal = 'float',
        blob = 'binary'
    },
}


local CompositeShape = class.CompositeShape.extends(Shape) {
    initialize = function (self, shape, options, member_name)
        Shape.initialize(self, shape, options, member_name)
        self.isComposite = true
        self.flattened = shape.flattened or false
    end 
}

local StructureShape = class.StructureShape.extends(CompositeShape) {
    initialize = function (self, shape, options, member_name)
        local required_map, first_init = nil, (not self:tryGetValue("isShape"))
        CompositeShape.initialize(self, shape, options, member_name)
        if first_init then
            self.defaultValue = {}
            self.members = {}
            self.member_names = {}
            self.required = {}
            self.isRequired = function () return false end
        end

        if shape.members then
            for k,v in pairs(shape.members) do
                self.members[k] = Shape.create(v, options or self.api.options, k)
                table.insert(self.member_names, k)
            end
            self.member_names = shape.xmlOrder or self.member_names
        end

        if shape.required then
            self.required = shape.required
            self.isRequired = function (name)
                if not required_map then
                    required_map = {}
                    for _, v in ipairs(self.required) do
                        required_map[v] = true
                    end
                end
                return required_map[name]
            end
        else
            self.required = false
        end

        self.resultWrapper = shape.resultWrapper or false
        self.payload = shape.payload or false

        if type(shape.xmlNamespace) == 'string' then
            self.xmlNamespaceUri = shape.xmlNamespace or false
        elseif type(shape.xmlNamespace) == 'table' then
            self.xmlNamespaceUri = shape.xmlNamespace.uri or false
            self.xmlNamespacePrefix = shape.xmlNamespace.prefix or false
        else
            self.xmlNamespaceUri = false
            self.xmlNamespacePrefix = false
        end
    end     
}

local ListShape = class.ListShape.extends(CompositeShape) {
    initialize = function (self, shape, options, member_name)
        local old_self, first_init = self, (not self:tryGetValue("isShape"))
        CompositeShape.initialize(self, shape, options, member_name)

        if first_init then
            self.defaultValue = {}
        end

        if shape.member then
            self.member = Shape.create(shape.member, options)
        end

        if self.flattened then
            local old_name = self.name
            self.name = old_self.member.name or old_name
        end
    end  
}

local MapShape = class.MapShape.extends(CompositeShape) {
    initialize = function (self, shape, options, member_name)
        local first_init = (not self:tryGetValue("isShape"))
        CompositeShape.initialize(self, shape, options, member_name)

        if first_init then
            self.defaultValue = {}
            self.key = Shape.create({["type"] = 'string'}, options)
            self.value = Shape.create({["type"] = 'string'}, options)
        end

        if shape.key then
            self.key = Shape.create(shape.key, options)
        end

        if shape.value then
            self.value = Shape.create(shape.value, options)
        end
    end
}

local TimestampShape = class.TimestampShape.extends(Shape) {
    initialize = function (self, shape, options, member_name)
        Shape.initialize(self, shape, options, member_name)
        if self.location == 'header' then
            self.timestampFormat = 'rfc822'
        elseif shape.timestampFormat then
            self.timestampFormat = shape.timestampFormat
        elseif self.api then
            if self.api:signature_timestamp_format() then
                self.timestampFormat = self.api:signature_timestamp_format()
            else
                local p = self.api.protocol
                if p == 'json' or p == 'rest-json' then
                    self.timestampFormat = 'unixTimestamp'
                elseif p == 'rest-xml' or p == 'query' or p == 'ec2' then
                    self.timestampFormat = 'iso8601'
                else
                    error('invalid proto:'..p)
                end
            end
        end
    end,
    -- seems there is no reason for convert something.
    -- because we generate timestamp data according to required format at first time.
    toType = function(self, value)
        return tostring(value)
    end,

    toWireFormat = function(self, value)
        return tostring(value)
    end,
}

local StringShape = class.StringShape.extends(Shape) {
}

local FloatShape = class.FloatShape.extends(Shape) {
    toType = function (self, value)
        return tonumber(value)
    end,
}

local IntegerShape = class.IntegerShape.extends(Shape) {
    toType = function (self, value)
        return tonumber(value)
    end,
}

local BinaryShape = class.BinaryShape.extends(Shape) {
    toType = function (self, value)
        return util.b64.decode(value)
    end,
    toWireFormat = function (self, value)
        return util.b64.encode(value)
    end,
}

local Base64Shape = class.Base64Shape.extends(BinaryShape) {
}

local BooleanShape = class.BooleanShape.extends(Shape) {
    toType = function (self, value)
        return value == 'true'
    end,
}

Shape.types = {
    structure = StructureShape,
    list = ListShape,
    map = MapShape,
    boolean = BooleanShape,
    timestamp = TimestampShape,
    float = FloatShape,
    integer = IntegerShape,
    string = StringShape,
    base64 = Base64Shape,
    binary = BinaryShape
}

Shape.shapes = {
  StructureShape = StructureShape,
  ListShape = ListShape,
  MapShape = MapShape,
  StringShape = StringShape,
  BooleanShape = BooleanShape,
  Base64Shape = Base64Shape
};

return Shape