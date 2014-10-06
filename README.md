#Twitter4D

##About this
The Simple Twitter API Wrapper Library For D Programming Language.  
(Sorry for my poor English)  
  
  
##Sample
You can access twitter api with simple way.  
This library provide 2 way to access TwitterAPI.
First way is direct.  
Second way is abstract.  
  
At first, write the first way.  
  
  
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

##First way
###POST API SAMPLE - First way : statuses/update.json 
`t4d.request("POST", "statuses/update.json", ["status" : "test"]);`
###GET API SAMPLE  - First way : account/verify_credentials.json
`writeln(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["":""])));`
###STREAMING API SAMPLE - First way : UserStream
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
  
  
##Documents - First way
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
  
  
##How to compile with Twitter4D - First way
`$ dmd FileName.d twitter4d.d -L-lcurl`  
  
  
##Second way
###POST API SAMPLE - Second way : statuses/update.json 
`t4d.status.update("test");`
###GET API SAMPLE  - Second way : statuses/home_timeline
```
auto timelineResult = t4d.statuses.home_timeline(["count" : "30"]);
  foreach(statusJson; timelineResult.json.array)
    writeln(timelineResult.getJsonElemFromJsonValue(statusJson, "user/screen_name")
        ~ " : " ~ timelineResult.getJsonElemFromJsonValue(statusJson, "text"));
```
  
  
##Documents - Second way
###Call API
t4d.(Resource family).(End Point)(some arguments);  
Ex:  
t4d.status.update("test");  
  
  
##How to compile with Twitter4D - Second way
`$ dmd FileName.d twitter4d.d twitterAPI.d -version=useTAPI -L-lcurl`  
  
  
##Notice - Second way
Implementation of all endpoints is not over yet.  
Finished:  

- statuses(without update\_with\_media)  

  
  
##LICENSE
The MIT LICENSE  
Copyright (C) 2014 alphaKAI
  

##Author
alphaKAI  
Twitter:[@alpha\_kai\_NET](https://twitter.com/alpha_kai_NET)  
WebSite:[alpha-kai-net.info](http://alpha-kai-net.info)  
