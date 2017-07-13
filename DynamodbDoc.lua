local DynamodbDoc = {}                                                                                                                                           
DynamodbDoc.__index = DynamodbDoc                                                                                                                                
                                                                                                                                                                 
function DynamodbDoc.New(Owner, DocName, AttrTypeMap)                                                                                                            
    local Self = {                                                                                                                                               
        Owner = Owner,                                                                                                                                           
        DocName = DocName,                                                                                                                                       
        AttrTypeMap = AttrTypeMap,                                                                                                                               
    }                                                                                                                                                            
    return setmetatable(Self, DynamodbDoc)                                                                                                                       
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbDoc:RootUnSerialize(RawData)                                                                                                                    
    local Result = {}                                                                                                                                            
    local Type, ValueSet                                                                                                                                         
    for K, V in pairs(RawData) do                                                                                                                                
        Type = self.AttrTypeMap[K]                                                                                                                               
        if Type == "M" then                                                                                                                                      
            Result[K] = self.Owner[K]:UnSerialize(V["M"])                                                                                                        
        else                                                                                                                                                     
            if Type == "NS" then                                                                                                                                 
                ValueSet = V[Type]                                                                                                                               
                for i = 1, #ValueSet do                                                                                                                          
                    ValueSet[i] = tonumber(ValueSet[i])                                                                                                          
                end                                                                                                                                              
            end                                                                                                                                                  
            Result[K] = V[Type]                                                                                                                                  
        end                                                                                                                                                      
    end                                                                                                                                                          
    return Result                                                                                                                                                
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbDoc:UnSerialize(RawData)                                                                                                                        
    local Result = {}                                                                                                                                            
    local Type, ValueSet                                                                                                                                         
    for K, V in pairs(RawData) do                                                                                                                                
        Type = self.AttrTypeMap[K]                                                                                                                               
        if  Type == "N" then                                                                                                                                     
            Result[K] = tonumber(V[Type])                                                                                                                        
        else                                                                                                                                                     
            if Type == "NS" then                                                                                                                                 
                ValueSet = V[Type]                                                                                                                               
                for i = 1, #ValueSet do                                                                                                                          
                    ValueSet[i] = tonumber(ValueSet[i])                                                                                                          
                end                                                                                                                                              
            end                                                                                                                                                  
            Result[K] = V[Type]                                                                                                                                  
        end                                                                                                                                                      
    end                                                                                                                                                          
    return Result                                                                                                                                                
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbDoc:RootPutItem(Data)                                                                                                                           
    local Result = {}                                                                                                                                            
    for K, V in pairs(Data) do                                                                                                                                   
        if self.AttrTypeMap[K] == "M" then                                                                                                                       
            Result[K] = {["M"] = self.Owner[K]:PutItem(V)}                                                                                                       
        else                                                                                                                                                     
            Result[K] = {[self.AttrTypeMap[K]] = V}                                                                                                              
        end                                                                                                                                                      
    end                                                                                                                                                          
    return Result                                                                                                                                                
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbDoc:PutItem(Data)                                                                                                                               
    local Result = {}                                                                                                                                            
    for K, V in pairs(Data) do                                                                                                                                   
        Result[K] = {[self.AttrTypeMap[K]] = V}                                                                                                                  
    end                                                                                                                                                          
    return Result                                                                                                                                                
end
function DynamodbDoc:RootUpdateItem(Data, AttributeValues)                                                                                                       
    local Expression = "set "                                                                                                                                    
    local Tag = 1                                                                                                                                                
    for K, V in pairs(Data) do                                                                                                                                   
        if self.AttrTypeMap[K] == "M" then                                                                                                                       
            Expression, Tag = self.Owner[K]:SerializeUpdateItem(V, AttributeValues, Expression, Tag)                                                             
        else                                                                                                                                                     
            Expression = Expression..K.." = :Value"..Tag..", "                                                                                                   
            AttributeValues[":Value"..Tag] = {[self.AttrTypeMap[K]] = V}                                                                                         
            Tag = Tag + 1                                                                                                                                        
        end                                                                                                                                                      
    end                                                                                                                                                          
    return string.sub(Expression, 1, #Expression-2), AttributeValues                                                                                             
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbDoc:SerializeUpdateItem(Data, AttributeValues, Expression, Tag)                                                                                 
    for K, V in pairs(Data) do                                                                                                                                   
        Expression = Expression..self.DocName.."."..K.." = Value"..Tag..", "                                                                                     
        AttributeValues[":Value"..Tag] = {[self.AttrTypeMap[K]] = V}                                                                                             
        Tag = Tag + 1                                                                                                                                            
    end                                                                                                                                                          
    return Expression, Tag                                                                                                                                       
end                                                                                                                                                              
                                                                                                                                                                 
--function DynamodbDoc:UpdateValue(Key, Value, IsAdd)                                                                                                            
--    if self.SetTypes[Key] then                                                                                                                                 
--        local ValueMap = self.AttrValueMap[Key]                                                                                                                
--        if IsAdd then                                                                                                                                          
--            if not ValueMap then                                                                                                                               
--                ValueMap = {}                                                                                                                                  
--                self.AttrValueMap[Key] = ValueMap                                                                                                              
--            end                                                                                                                                                
--            ValueMap[Value] = IsAdd                                                                                                                            
--        else                                                                                                                                                   
--            if ValueMap then                                                                                                                                   
--                ValueMap[Value] = IsAdd                                                                                                                        
--            end                                                                                                                                                
--        end                                                                                                                                                    
--        return true                                                                                                                                            
--    elseif self.ScalarTypes[Key] then                                                                                                                          
--        self.AttrValueMap[Key] = Value                                                                                                                         
--        return true                                                                                                                                            
--    end                                                                                                                                                        
--end                                                                                                                                                            
                                                                                                                                                                 
function DynamodbDoc:RootQueryItem(Condition, Values)                                                                                                            
    local Expression = ""                                                                                                                                        
    local Tag = 1                                                                                                                                                
    for K, V in pairs(Condition) do                                                                                                                              
        Expression = Expression..K.." = :Value"..Tag..", "                                                                                                       
        Values[":Value"..Tag] = {[self.AttrTypeMap[K]] = V}                                                                                                      
        Tag = Tag + 1                                                                                                                                            
    end                                                                                                                                                          
    return string.sub(Expression, 1, #Expression-2), Values                                                                                                      
end                                                                                                                                                              
                                                                                                                                                                 
return DynamodbDoc
