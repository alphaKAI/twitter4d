#Twitter4D

##About this
The Simple Twitter API Wrapper Library For D Programming Language.  
  
  
##Usage
You can access twitter api simple way.  
'''d
//test.d
import twitter4d;
// Not Requirements
import std.stdio,
       std.json;

void main(){
  Twitter4D t4d = new Twitter4D([
      "consumerKey"       : "Your Consumer Key",
      "consumerSecret"    : "Your Consumer Secret",
      "accessToken"       : "Your Access Token",
      "accessTokenSecret" : "Your Access Token Secret"]);

  t4d.request("POST", "statuses/update.json", ["status" : "test"]);
  writeln(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["":""])));
}
'''
  
  
##Documents
###POST
'(Instance of Twitter4D).request("POST", "endPoint", ["additional" : "parameters"]);'  
Retrun value : plain json String  
###GET
'(Instance of Twitter4D).request("GET", "endPoint", ["additional": "parameters"]);'  
Return value : plain json String  
  
<<<<<<< HEAD
=======
##How to compile with Twitter4D
`$ dmd FileName.d twitter4d.d -L-lcurl`  
  
>>>>>>> f746828... fix : README.md
  
##LICENSE
The MIT LICENSE  
Copyright (C) 2014 alphaKAI
  
  
##Author
alphaKAI  
Twitter:[@alpha\_kai\_NET](https://twitter.com/alpha_kai_NET)  
WebSite:[alpha-kai-net.info](http://alpha-kai-net.info)  
