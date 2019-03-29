/*
  The Simple Twitter API Wrapper For D Programming Language.
  Copyright (C) alphaKAI 2014-2016 http://alpha-kai-net.info
  THE MIT LICENSE.
*/

import std.digest.hmac,
       std.digest.sha,
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
import std.uri : encodeComponentUnsafe = encodeComponent;

import core.exception;

class Twitter4D {
  public bool developer;
  protected string consumerKey,
                 consumerSecret,
                 accessToken,
                 accessTokenSecret;

  protected static string baseUrl      = "https://api.twitter.com/1.1/";
  protected static string oauthBaseUrl = "https://api.twitter.com/oauth/";


  this(string[string] oauthHash) {
    mixin ("consumerKey"      .initializeByHashMap("oauthHash"));
    mixin ("consumerSecret"   .initializeByHashMap("oauthHash"));

    if ("accessToken" in oauthHash) {
      mixin ("accessToken"      .initializeByHashMap("oauthHash"));
    }

    if("accessTokenSecret" in oauthHash) {
      mixin ("accessTokenSecret".initializeByHashMap("oauthHash"));
    }
  }

  this(string consumerKey, string consumerSecret,
      string accessToken, string accessTokenSecret) {
    this.consumerKey       = consumerKey;
    this.consumerSecret    = consumerSecret;
    this.accessToken       = accessToken;
    this.accessTokenSecret = accessTokenSecret;
  }

  this(string consumerKey, string consumerSecret) {
    this.consumerKey    = consumerKey;
    this.consumerSecret = consumerSecret;
  }

  public string[string] getAccessToken() {
    string[string] accessTokens = requestAccessToken;
    return accessTokens;
  }

  public void printAccessTokens() {
    if(developer) {
      writeln("accessToken : ", accessToken);
      writeln("accessTokenSecret : ", accessTokenSecret);
    }
  }

  public void setAccessToken(string[string] accessTokens) {
    this.accessToken       = accessTokens["accessToken"];
    this.accessTokenSecret = accessTokens["accessTokenSecret"];
  }

  //Need to more consideration
  protected auto oauthRequest(string type, string endPoint, string[string] paramsArgument = null) {
    string tmp = baseUrl;
    baseUrl    = oauthBaseUrl;
    scope(exit) {
      baseUrl = tmp;
    }

    return request(type, endPoint, paramsArgument);
  }

  public auto customUrlRequest(string baseUrl, string type, string endPoint, string[string] paramsArgument = null) {
    string tmp   = this.baseUrl;
    this.baseUrl = baseUrl;
    scope(exit) {
      this.baseUrl = tmp;
    }

    return request(type, endPoint, paramsArgument);
  }

  // post/get request function
  // Ex: request("POST", "statuses/update.json" ["status": "hoge"]);
  public auto request(string type, string endPoint, string[string] paramsArgument = null) {
    string method = (){
      if (type == "get" || type == "GET") {
        return "GET";
      } else if (type == "post" || type == "POST") {
        return "POST";
      } else {
        throw new Error("Method Name Error");
      }
    }();

    // support the old way to indicate no parameters
    // deprecated
    if (paramsArgument == ["":""]) {
      paramsArgument = null;
    }

    string[string] params = buildParams(paramsArgument);
    string url = baseUrl ~ endPoint;

    string oauthSignature = signature(consumerSecret, accessTokenSecret, method, url, params);
    params["oauth_signature"] = oauthSignature;

    auto authorizeKeys = params.keys.filter!q{a.startsWith("oauth_")};
    auto authorize     = "OAuth " ~ authorizeKeys.map!(k => k ~ "=" ~ params[k]).join(",");

    string path = params.keys.map!(k => k ~ "=" ~ params[k]).join("&");

    auto http = HTTP();

    http.addRequestHeader("Authorization", authorize);

    if (method == "GET") {
      return get(url ~ "?" ~ path, http);
    } else if (method == "POST") {
      return post(url, path, http);
    }

    return null;
  }

  public auto stream(string url = "https://userstream.twitter.com/1.1/user.json") {
    string[string] params = buildParams();

    string oauthSignature = signature(consumerSecret, accessTokenSecret, "GET", url, params);
    params["oauth_signature"] = oauthSignature;

    string path = params.keys.map!(k => k ~ "=" ~ params[k]).join("&");

    auto streamSocket = byLineAsync(url ~ "?" ~ path);

    return streamSocket;
  }

  protected string[string] buildParams(string[string] additionalParam = null) {
    import std.uuid : randomUUID;
    string now = Clock.currTime.toUnixTime.to!string;
    string[string] params = [
      "oauth_consumer_key"     : consumerKey,
      "oauth_nonce"            : randomUUID().to!string,
      "oauth_signature_method" : "HMAC-SHA1",
      "oauth_timestamp"        : now,
      "oauth_token"            : accessToken,
      "oauth_version"          : "1.0"];

    if (additionalParam !is null) {
      foreach (key, value; additionalParam) {
        params[key] = value;
      }
    }

    foreach (key, value; params) {
      params[key] = encodeComponent(value);
    }

    return params;
  }

  protected string signature(string consumerSecret, string accessTokenSecret, string method, string url, string[string] params) {

    auto query = std.algorithm.sort(params.keys).map!(k => k ~ "=" ~ params[k]).join("&");
    auto key  = [consumerSecret, accessTokenSecret].map!(x => encodeComponent(x)).join("&");
    auto base = [method, url, query].map!(x => encodeComponent(x)).join("&");
    string oauthSignature = encodeComponent(Base64.encode(base.representation.hmac!SHA1(key.representation)));

    return oauthSignature;
  }

  protected static string[string] toToken(string str) {
    string[string] result;

    foreach (x; str.split("&").map!q{a.split("=")}) {
      result[x[0]] = x[1];
    }

    return result;
  }

  protected string encodeComponent(string s) {
    char hexChar(ubyte c) {
      assert(c >= 0 && c <= 15);
      if (c < 10)
        return cast(char)('0' + c);
      else
        return cast(char)('A' + c - 10);
    }

    enum InvalidChar = ctRegex!`[!\*'\(\)]`;

    return s.encodeComponentUnsafe.replaceAll!((s) {
          char c = s.hit[0];
          char[3] encoded;
          encoded[0] = '%';
          encoded[1] = hexChar((c >> 4) & 0xF);
          encoded[2] = hexChar(c & 0xF);
          return encoded[].idup;
        })(InvalidChar);
  }

  // Experimental implementation
  string[string] requestAccessToken() {
    string[string] requestToken = toToken(oauthRequest("GET", "request_token").to!string);

    auto authorize_uri = oauthBaseUrl ~ "authorize" ~ "?oauth_token=" ~ requestToken["oauth_token"];
    writeln("Please access this uri and input pin code");
    authorize_uri.writeln;

    write("PIN : ");
    auto verifier = readln.chomp;

    this.accessToken       = requestToken["oauth_token"];
    this.accessTokenSecret = requestToken["oauth_token_secret"];

    string[string] tokens = toToken(oauthRequest("GET", "access_token", ["oauth_verifier": verifier]).to!string);
    this.accessToken       = tokens["oauth_token"];
    this.accessTokenSecret = tokens["oauth_token_secret"];

    return ["accessToken"       : tokens["oauth_token"],
           "accessTokenSecret" : tokens["oauth_token_secret"]];
  }
}

//sub functions
protected static string initializeByHashMap(string varName, string hmName) {
  import std.string : format;
  return "try this.%s = %s[\"%s\"]; catch (RangeError e) throw new Error(\"%s\");"
    .format(varName, hmName, varName,
        "%s must have an item with key \\\"%s\\\"".format(hmName, varName));
}
