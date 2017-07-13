local DynamodbDoc = require "Dynamodb.DynamodbDoc"                                                                                                               
local nTable = require "nTable"                                                                                                                                  
                                                                                                                                                                 
local DynamodbItem = {}                                                                                                                                          
DynamodbItem.__index = DynamodbItem                                                                                                                              
                                                                                                                                                                 
function DynamodbItem.New(Owner, TableProto)                                                                                                                     
    local Self = {                                                                                                                                               
        Owner = Owner                                                                                                                                            
    }                                                                                                                                                            
    for Name, AttrTypeMap in pairs(TableProto.Docs) do                                                                                                           
        Self[Name] = DynamodbDoc.New(Self, Name, AttrTypeMap)                                                                                                    
    end                                                                                                                                                          
    return setmetatable(Self, DynamodbItem)                                                                                                                      
end                                                                                                                                                              
                                                                                                                                                                 
                                                                                                                                                                 
function DynamodbItem:SerializePutItem(Data)                                                                                                                     
    return self[self.Owner.TableName]:RootPutItem(Data)                                                                                                          
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbItem:SerializeUpdateItem(Data)                                                                                                                  
    local AttributeValues = {}                                                                                                                                   
    local Expression = self[self.Owner.TableName]:RootUpdateItem(Data, AttributeValues)                                                                          
    return Expression, AttributeValues                                                                                                                           
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbItem:SerializeQueryItem(Condition)                                                                                                              
    local Values = {}                                                                                                                                            
    local Expression = self[self.Owner.TableName]:RootQueryItem(Condition, Values)                                                                               
    return Expression, Values                                                                                                                                    
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbItem:UnSerialize(RawData)                                                                                                                       
    return self[self.Owner.TableName]:RootUnSerialize(RawData)                                                                                                   
end                                                                                                                                                              
                                                                                                                                                                 
return DynamodbItem
