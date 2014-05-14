/*
  The Simple Twitter API Wrapper For D Programming Language.
  Copyright (C) alphaKAI 2014 http://alpha-kai-net.info
  THE MIT LICENSE.
*/

import std.digest.sha,
       std.algorithm,
       std.datetime,
       std.net.curl,
       std.base64,
       std.array,
       std.regex,
       std.stdio,
       std.json,
       std.conv,
       std.uri;

class Twitter4D{
  private{
    string consumerKey,
           consumerSecret,
           accessToken,
           accessTokenSecret;

    string baseUrl = "https://api.twitter.com/1.1/";
  }

  this(string[string] oauthHash){
    if(oauthHash.length < 4)
      throw new Error("Error: When Initialize this class, requirements 4 element");

    consumerKey       = oauthHash["consumerKey"];
    consumerSecret    = oauthHash["consumerSecret"];
    accessToken       = oauthHash["accessToken"];
    accessTokenSecret = oauthHash["accessTokenSecret"];
  }

  this(string consumerKey, string consumerSecret,
      string accessToken, string accessTokenSecret){
    this.consumerKey       = consumerKey;
    this.consumerSecret    = consumerSecret;
    this.accessToken       = accessToken;
    this.accessTokenSecret = accessTokenSecret;
  }

  // post/get request function
  // Ex: request("POST", "statuses/update.json" ["status": "hoge"]);
  auto request(string type, string endPoint, string[string] paramsArgument){
    string method = (){
      if(type == "get" || type == "GET")
        return "GET";
      else if(type == "post" || type == "POST")
        return "POST";
      else
        throw new Error("Method Name Error");
    }();

    string[string] params = buildParams(paramsArgument);
    string url = baseUrl ~ endPoint;

    string oauthSignature = signature(consumerSecret, accessTokenSecret, method, url, params);
    params["oauth_signature"] = oauthSignature;

    auto authorizeKeys = params.keys.filter!q{a.countUntil("oauth_")==0};
    auto authorize     = "OAuth " ~ authorizeKeys.map!(k => k ~ "=" ~ params[k]).join(",");

    string path = params.keys.map!(k => k ~ "=" ~ params[k]).join("&");

    auto http = HTTP();

    http.addRequestHeader("Authorization", authorize);
    if(method == "GET")
      return get(url ~ "?" ~ path, http);
    else if(method == "POST")
      return post(url, path, http);
    
    return null;
  }


  //Testing
  auto stream(string url = "https://userstream.twitter.com/1.1/user.json"){
    string[string] params = buildParams();
    
    string oauthSignature = signature(consumerSecret, accessTokenSecret, "GET", url, params);
    params["oauth_signature"] = oauthSignature;

    auto authorizeKeys = params.keys.filter!q{a.countUntil("oauth_")==0};
    auto authorize = "OAuth " ~ authorizeKeys.map!(k => k ~ "=" ~ params[k]).join(",");

    string path = params.keys.map!(k => k ~ "=" ~ params[k]).join("&");

    auto http = HTTP();
    http.addRequestHeader("Authorization", authorize);
    http.method = HTTP.Method.get;
    auto streamSocket = byLineAsync(url ~ "?" ~ path);

    return streamSocket;
  }

  private{
    string[string] buildParams(string[string] additionalParam = ["":""]){
      string now = Clock.currTime.toUnixTime.to!string;
      string[string] params = [
        "oauth_consumer_key" : consumerKey,
        "oauth_nonce" : "4324yfe",
        "oauth_signature_method" : "HMAC-SHA1",
        "oauth_timestamp" : now,
        "oauth_token" : accessToken,
        "oauth_version" : "1.0"];
      
      if(additionalParam != ["":""])
        foreach(key, value; additionalParam)
          params[key] = value;
      foreach(key, value; params)
        params[key] = encodeComponent(value);

      return params;
    }

    ubyte[] hmac_sha1(in string key, in string message){
      auto padding(in ubyte[] k){
        auto h = (64 < k.length)? sha1Of(k): k;
        return h ~ new ubyte[64 - h.length];
      }
      const k = padding(cast(ubyte[])key);
      return sha1Of((k.map!q{cast(ubyte)(a^0x5c)}.array) ~ sha1Of((k.map!q{cast(ubyte)(a^0x36)}.array) ~ cast(ubyte[])message)).dup;
    }

    string signature(string consumerSecret, string accessTokenSecret, string method, string url, string[string] params){

      auto query = params.keys.sort.map!(k => k ~ "=" ~ params[k]).join("&");
      auto key = [consumerSecret, accessTokenSecret].map!encodeComponent.join("&");
      auto base = [method, url, query].map!encodeComponent.join("&");

      string oauthSignature = encodeComponent(Base64.encode(hmac_sha1(key, base)));

      return oauthSignature;
    }
  }
}


