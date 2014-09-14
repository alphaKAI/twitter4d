#Twitter4D

##About this
The Simple Twitter API Wrapper Library For D Programming Language.  
  
  
##Sample
You can access twitter api with simple way.  
  
  
###This Sample Requirements
```d
import std.stdio,
       std.regex,
       std.json,
       std.conv;
```
###Create Instance
```d
Twitter4D t4d = new Twitter4D([
    "consumerKey"       : "Your Consumer Key",
    "consumerSecret"    : "Your Consumer Secret",
    "accessToken"       : "Your Access Token",
    "accessTokenSecret" : "Your Access Token Secret"]);
```
or  
```d
Twitter4D t4d = new Twitter4D(
    "Your Consumer Key",
    "Your Consumer Secret",
    "Your Access Token",
    "Your Access Token Secret"]); 
```
###POST API SAMPLE : statuses/update.json 
`t4d.request("POST", "statuses/update.json", ["status" : "test"]);`
###GET API SAMPLE : account/verify_credentials.json
`writeln(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["":""])));`
###STREAMING API SAMPLE : UserStream
```d
foreach(line; t4d.stream()){
  if(match(line.to!string, regex(r"\{.*\}"))){
    auto parsed = parseJSON(line.to!string);
    if("text" in parsed.object)//tweet
      writefln("\r[%s]:%s - [%s]", parsed.object["user"].object["name"],
          parsed["created_at"],
          parsed.object["text"]);
  }
}
``` 
  
  
##Documents
###POST API
`(Instance of Twitter4D).request("POST", "endPoint", ["additional" : "parameters"]);`  
Retrun value : plain json String  
###GET API
`(Instance of Twitter4D).request("GET", "endPoint", ["additional": "parameters"]);`  
Return value : plain json String  
###STREAMING API
default streaming api is UserStream  
`(Instance of Twitter4D).stream("endPoint URL(Full)");`  
Return value : streaming api session  
  
  
##How to compile with Twitter4D
`$ dmd FileName.d twitter4d.d -L-lcurl`  
  
  
##LICENSE
The MIT LICENSE  
Copyright (C) 2014 alphaKAI
  

##Author
alphaKAI  
Twitter:[@alpha\_kai\_NET](https://twitter.com/alpha_kai_NET)  
WebSite:[alpha-kai-net.info](http://alpha-kai-net.info)  
