local DynamodbItem = require "Dynamodb.DynamodbItem"                                                                                                             
local nTable = require "nTable"                                                                                                                                  
                                                                                                                                                                 
local DynamodbTable = {}                                                                                                                                         
DynamodbTable.__index = DynamodbTable                                                                                                                            
                                                                                                                                                                 
function DynamodbTable.New(TableProto)                                                                                                                           
    local Self = {                                                                                                                                               
        TableName = TableProto.TableName,                                                                                                                        
        PartitionKeyName = TableProto.PartitionKey.Name,                                                                                                         
        PartitionKeyType = TableProto.PartitionKey.Type,                                                                                                         
        SortKeyName = TableProto.SortKey.Name,                                                                                                                   
        SortKeyType = TableProto.SortKey.Type,                                                                                                                   
    }                                                                                                                                                            
    Self.ItemObj = DynamodbItem.New(Self, TableProto)                                                                                                            
    return setmetatable(Self, DynamodbTable)                                                                                                                     
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbTable:UpdateItem(Data)                                                                                                                          
    local PartitionKeyName = self.PartitionKeyName                                                                                                               
    local PartitionKeyType = self.PartitionKeyType                                                                                                               
    local SortKeyName = self.SortKeyName                                                                                                                         
    local SortKeyType = self.SortKeyType                                                                                                                         
                                                                                                                                                                 
    local Key                                                                                                                                                    
    if SortKeyName then                                                                                                                                          
        Key = {                                                                                                                                                  
            [PartitionKeyName] = {[PartitionKeyType] = Data[PartitionKeyName]},                                                                                  
            [SortKeyName] = {[SortKeyType] = Data[SortKeyName]},                                                                                                 
        }                                                                                                                                                        
    else                                                                                                                                                         
        Key = {[PartitionKeyName] = {[PartitionKeyType] = Data[PartitionKeyName]}}                                                                               
    end                                                                                                                                                          
    local Result = {                                                                                                                                             
        TableName = self.TableName,                                                                                                                              
        Key = Key,                                                                                                                                               
    }                                                                                                                                                            
    local Expression, AttributeValues = self.ItemObj:SerializeUpdateItem(Data)                                                                                   
    Result.UpdateExpression = Expression                                                                                                                         
    Result.ExpressionAttributeValues = AttributeValues                                                                                                           
    return Result                                                                                                                                                
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbTable:PutItem(Data)                                                                                                                             
    local SeriaItemValue = self.ItemObj:SerializePutItem(Data)                                                                                                   
    nTable.printTable(SeriaItemValue)                                                                                                                            
    return {                                                                                                                                                     
        TableName = self.TableName,                                                                                                                              
        Item = SeriaItemValue,                                                                                                                                   
    }                                                                                                                                                            
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbTable:DeleteItem(PartitionKey, SortKey)                                                                                                         
    if self.SortKeyName then                                                                                                                                     
        return {                                                                                                                                                 
            TableName = self.TableName,                                                                                                                          
            Key = {                                                                                                                                              
                [self.PartitionKeyName] = {[self.PartitionKeyType] = PartitionKey},                                                                              
                [self.SortKeyName] = {[self.SortKeyType] = SortKey},                                                                                             
            }                                                                                                                                                    
        }                                                                                                                                                        
    else                                                                                                                                                         
        return {                                                                                                                                                 
            TableName = self.TableName,                                                                                                                          
            Key = {                                                                                                                                              
                [self.PartitionKeyName] = {[self.PartitionKeyType] = PartitionKey},                                                                              
            }                                                                                                                                                    
        }                                                                                                                                                        
    end                                                                                                                                                          
end

function DynamodbTable:GetItem(PartitionKey, SortKey)                                                                                                            
    if self.SortKeyName then                                                                                                                                     
        return {                                                                                                                                                 
            TableName = self.TableName,                                                                                                                          
            Key = {                                                                                                                                              
                [self.PartitionKeyName] = {[self.PartitionKeyType] = PartitionKey},                                                                              
                [self.SortKeyName] = {[self.SortKeyType] = SortKey},                                                                                             
            },                                                                                                                                                   
            ConsistentRead = true,                                                                                                                               
        }                                                                                                                                                        
    else                                                                                                                                                         
        return {                                                                                                                                                 
            TableName = self.TableName,                                                                                                                          
            Key = {                                                                                                                                              
                [self.PartitionKeyName] = {[self.PartitionKeyType] = PartitionKey},                                                                              
            },                                                                                                                                                   
            ConsistentRead = true,                                                                                                                               
        }                                                                                                                                                        
    end                                                                                                                                                          
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbTable:Query(Data)                                                                                                                               
    local Expression, AttributeValues = self.ItemObj:SerializeQueryItem(Data.Condition)                                                                          
    return {                                                                                                                                                     
        TableName = Data.TableName,                                                                                                                              
        ConsistentRead = true,                                                                                                                                   
        KeyConditionExpression = Expression,                                                                                                                     
        ExpressionAttributeValues = AttributeValues,                                                                                                             
    }                                                                                                                                                            
end                                                                                                                                                              
                                                                                                                                                                 
--TODO                                                                                                                                                           
function DynamodbTable:BatchGetItem(PartitionKey, SortKey)                                                                                                       
        return {                                                                                                                                                 
            RequestItems = {                                                                                                                                     
                [self.TableName] = {                                                                                                                             
                    ConsistentRead = true,                                                                                                                       
                    Keys = {                                                                                                                                     
                        {                                                                                                                                        
                            [self.PartitionKeyName] = {[self.PartitionKeyType] = PartitionKey},                                                                  
                            [self.SortKeyName] = {[self.SortKeyType] = SortKey},                                                                                 
                        },                                                                                                                                       
                    },                                                                                                                                           
                },                                                                                                                                               
            },                                                                                                                                                   
            ReturnConsumedCapacity = "TOTAL",                                                                                                                    
        }                                                                                                                                                        
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbTable:UnSerialize(RawData)                                                                                                                      
    return self.ItemObj:UnSerialize(RawData)                                                                                                                     
end                                                                                                                                                              
                                                                                                                                                                 
return DynamodbTable
