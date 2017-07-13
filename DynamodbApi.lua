local nTable = require "nTable"                                                                                                                                  
local DynamodbApi = {}                                                                                                                                           
DynamodbApi.__index = DynamodbApi                                                                                                                                
                                                                                                                                                                 
function DynamodbApi.New(AwsHandle, TableApi)                                                                                                                    
    local Self = {                                                                                                                                               
        AwsHandle = AwsHandle,                                                                                                                                   
        TableName = TableName,                                                                                                                                   
        TableApi = TableApi,                                                                                                                                     
    }                                                                                                                                                            
    return setmetatable(Self, DynamodbApi)                                                                                                                       
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbApi:GetItem(PartitionKey, SortKey)                                                                                                              
    local GetItemBody = self.TableApi:GetItem(PartitionKey, SortKey)                                                                                             
    local Ok, Result = self.AwsHandle.DynamoDB:api():GetItem(GetItemBody)                                                                                        
    nTable.printTable(Result)                                                                                                                                    
    if Ok then                                                                                                                                                   
        return self.TableApi:UnSerialize(Result.Item)                                                                                                            
    end                                                                                                                                                          
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbApi:DeleteItem(PartitionKey, SortKey)                                                                                                           
    local DeleteItemBody = self.TableApi:DeleteItem(PartitionKey, SortKey)                                                                                       
    return self.AwsHandle.DynamoDB:api():DeleteItem(DeleteItemBody)                                                                                              
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbApi:UpdateItem(Data)                                                                                                                            
    local UpdateItemBody = self.TableApi:UpdateItem(Data)                                                                                                        
    return self.AwsHandle.DynamoDB:api():UpdateItem(UpdateItemBody)                                                                                              
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbApi:PutItem(Data)                                                                                                                               
    local PutItemBody = self.TableApi:PutItem(Data)                                                                                                              
    return self.AwsHandle.DynamoDB:api():PutItem(PutItemBody)                                                                                                    
end                                                                                                                                                              
                                                                                                                                                                 
function DynamodbApi:Query(Data)                                                                                                                                 
    local PutItemBody = self.TableApi:Query(Data)                                                                                                                
    nTable.printTable(PutItemBody)                                                                                                                               
    local Ok, Result = self.AwsHandle.DynamoDB:api():Query(PutItemBody)                                                                                          
    nTable.printTable(Result)                                                                                                                                    
end                                                                                                                                                              
                                                                                                                                                                 
--TODO                                                                                                                                                           
function DynamodbApi:BatchGetItem(Data, SortKey)                                                                                                                 
    local BatchGetItemBody = self.TableApi:BatchGetItem(Data, SortKey)                                                                                           
    nTable.printTable(BatchGetItemBody)                                                                                                                          
    local Ok, PartResult = self.AwsHandle.DynamoDB:api():BatchGetItem(BatchGetItemBody)                                                                          
    local Ans = self.TableApi:UnSerialize(PartResult.Responses[self.TableName])                                                                                  
    if Ok then                                                                                                                                                   
        if next(PartResult.UnprocessedKeys) then                                                                                                                 
            local BatchGetItemBody = self.TableApi:BatchGetItem(PartResult.UnprocessedKeys)                                                                      
            Ok, PartResult = self.AwsHandle.DynamoDB:api():BatchGetItem(BatchGetItemBody)                                                                        
            local TempAns = self.TableApi:UnSerialize(PartResult.Responses[self.TableName])                                                                      
            for _, V in pairs(TempAns) do                                                                                                                        
                table.insert(Ans, V)                                                                                                                             
            end                                                                                                                                                  
        end                                                                                                                                                      
    end                                                                                                                                                          
    return Ans                                                                                                                                                   
end                                                                                                                                                              
                                                                                                                                                                 
return DynamodbApi  
