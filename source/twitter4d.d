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
       std.format,
       std.string,
       std.array,
       std.regex,
       std.stdio,
       std.json,
       std.conv;
import core.exception;
class Twitter4D{
  bool developer;
  private{
    string consumerKey,
           consumerSecret,
           accessToken,
           accessTokenSecret;

    string baseUrl      = "https://api.twitter.com/1.1/";
    string oauthBaseUrl = "https://api.twitter.com/oauth/";
  }

  this(string[string] oauthHash){
    mixin ("consumerKey"      .initializeByHashMap("oauthHash"));
    mixin ("consumerSecret"   .initializeByHashMap("oauthHash"));

    if("accessToken" in oauthHash)
      mixin ("accessToken"      .initializeByHashMap("oauthHash"));
    
    if("accessTokenSecret" in oauthHash)
      mixin ("accessTokenSecret".initializeByHashMap("oauthHash"));
  }

  this(string consumerKey, string consumerSecret,
      string accessToken, string accessTokenSecret){
    this.consumerKey       = consumerKey;
    this.consumerSecret    = consumerSecret;
    this.accessToken       = accessToken;
    this.accessTokenSecret = accessTokenSecret;
  }

  this(string consumerKey, string consumerSecret){
    this.consumerKey    = consumerKey;
    this.consumerSecret = consumerSecret;
  }
  
  string[string] getAccessToken(){
    string[string] accessTokens = requestAccessToken;
    return accessTokens;
  }

  void printAccessTokens(){
    if(developer){
      writeln("accessToken : ", accessToken);
      writeln("accessTokenSecret : ", accessTokenSecret);
    }
  }

  void setAccessToken(string[string] accessTokens){
    this.accessToken       = accessTokens["accessToken"];
    this.accessTokenSecret = accessTokens["accessTokenSecret"];
  }

  //Need to more consideration
  auto oauthRequest(string type, string endPoint, string[string] paramsArgument = null){
    auto tmp = baseUrl;
    baseUrl  = oauthBaseUrl;
    scope(exit)
      baseUrl = tmp;

    return request(type, endPoint, paramsArgument);
  }

  // post/get request function
  // Ex: request("POST", "statuses/update.json" ["status": "hoge"]);
  auto request(string type, string endPoint, string[string] paramsArgument = null){
    string method = (){
      if(type == "get" || type == "GET")
        return "GET";
      else if(type == "post" || type == "POST")
        return "POST";
      else
        throw new Error("Method Name Error");
    }();

    // support the old way to indicate no parameters
    if (paramsArgument == ["":""]) paramsArgument = null;

    string[string] params = buildParams(paramsArgument);
    string url = baseUrl ~ endPoint;
    
    string oauthSignature = signature(consumerSecret, accessTokenSecret, method, url, params);
    params["oauth_signature"] = oauthSignature;

    auto authorizeKeys = params.keys.filter!q{a.startsWith("oauth_")};
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

    auto authorizeKeys = params.keys.filter!q{a.startsWith("oauth_")};
    auto authorize = "OAuth " ~ authorizeKeys.map!(k => k ~ "=" ~ params[k]).join(",");

    string path = params.keys.map!(k => k ~ "=" ~ params[k]).join("&");

    auto http = HTTP();
    http.addRequestHeader("Authorization", authorize);
    http.method = HTTP.Method.get;
    auto streamSocket = byLineAsync(url ~ "?" ~ path);

    return streamSocket;
  }

  private{
    static string urlEncode(string urlString){
      // Exclude A..Z a..z 0..9 - . _ ~
      // See https://dev.twitter.com/oauth/overview/percent-encoding-parameters
      import std.ascii : letters, digits;
      enum exChars = letters ~ digits ~ "-._~";

      auto result = appender!string;
      result.reserve(urlString.length); // result.data.length >= urlString.length
      foreach(char charc; urlString){
        if(exChars.canFind(charc))
          result ~= charc;
        else
          formattedWrite(result, "%%%X", charc);
      }
      return result.data;
    }

    string[string] buildParams(string[string] additionalParam = null){
      import std.uuid : randomUUID;
      string now = Clock.currTime.toUnixTime.to!string;
      string[string] params = [
        "oauth_consumer_key"     : consumerKey,
        "oauth_nonce"            : randomUUID().to!string,
        "oauth_signature_method" : "HMAC-SHA1",
        "oauth_timestamp"        : now,
        "oauth_token"            : accessToken,
        "oauth_version"          : "1.0"];

      if(additionalParam !is null)
        foreach(key, value; additionalParam)
          params[key] = value;

      foreach(key, value; params)
        params[key] = urlEncode(value);

      return params;
    }

    static ubyte[] hmac_sha1(in string key, in string message){
      static auto padding(in ubyte[] k){
        auto h = (64 < k.length)? sha1Of(k): k;
        return h ~ new ubyte[64 - h.length];
      }
      const k = padding(cast(ubyte[])key);
      return sha1Of((k.map!q{cast(ubyte)(a^0x5c)}.array) ~ sha1Of((k.map!q{cast(ubyte)(a^0x36)}.array) ~ cast(ubyte[])message)).dup;
    }

    string signature(string consumerSecret, string accessTokenSecret, string method, string url, string[string] params){

      auto query = std.algorithm.sort(params.keys).map!(k => k ~ "=" ~ params[k]).join("&");
      auto key  = [consumerSecret, accessTokenSecret].map!(x => urlEncode(x)).join("&");
      auto base = [method, url, query].map!(x => urlEncode(x)).join("&");
      string oauthSignature = urlEncode(Base64.encode(hmac_sha1(key, base)));

      return oauthSignature;
    }

    string[string] toToken(string str){
      string[string] result;
      foreach (x; str.split("&").map!q{a.split("=")})
        result[x[0]] = x[1];
      return result;
    }

    //Test implementation
    string[string] requestAccessToken(){
      string[string] requestToken = toToken(oauthRequest("GET", "request_token").to!string);

      auto authorize_uri = oauthBaseUrl ~ "authorize" ~ "?oauth_token=" ~ requestToken["oauthToken"];
      writeln("Please access this uri and input pin code");
      authorize_uri.writeln;

      write("PIN : ");
      auto verifier = readln.chomp;

      this.accessToken       = requestToken["oauthToken"];
      this.accessTokenSecret = requestToken["oauthTokenSecret"];

      string[string] tokens = toToken(oauthRequest("GET", "access_token", ["oauth_verifier": verifier]).to!string);
      return ["accessToken"       : tokens["oauth_token"],
              "accessTokenSecret" : tokens["oauth_token_secret"]];
    }
  }
}

//sub functions
private string initializeByHashMap(string varName, string hmName){
  import std.string : format;
  return "try this.%s = %s[\"%s\"]; catch (RangeError e) throw new Error(\"%s\");"
    .format(varName, hmName, varName,
        "%s must have an item with key \\\"%s\\\"".format(hmName, varName));
}
