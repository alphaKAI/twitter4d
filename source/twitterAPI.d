/*
  Twitter API wrapper.
  Using my Twitter API Core Wrapper -Twitter4D-

  The MIT License

  Copyright (C) 2014 alphaKAI http://alpha-kai-net.info
 */
public import std.string;
import std.json,
       std.conv;

mixin template TwitterAPI(){
  struct APICallResult{
    bool success;
    JSONValue json;

    //JSON Assessor
    string getJsonElem(in string path){
      return getJsonElemFromJsonValue(json, path);
    }
    
    string getJsonArrayElem(in int offset, in string path){
      return getJsonElemFromJsonValue(json[offset], path);
    }

    string getJsonElemFromJsonValue(JSONValue from, in string path){
      foreach(key; path.split("/"))
        from = from.object[key.to!string];

      return from.to!string;
    }

    string getJsonArrayElemFromJsonValue(JSONValue from, in int offset, in string path){
      return getJsonElemFromJsonValue(from[offset], path);
    }
  }

  private APICallResult generateResult(in bool status, in JSONValue jsonData){
    APICallResult result;

    result.success = status;
    result.json    = jsonData;

    return result;
  }

  class Statuses{
    //GET statuses/mentions_timeline
    APICallResult mentions_timeline(string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/mentions_timeline.json", params)));
    }

    //GET statuses/user_timeline
    APICallResult user_timeline(string[string] params = string[string].init){
     return generateResult(true, parseJSON(request("GET", "statuses/user_timeline.json", params))); 
    }
    
    //GET statuses/home_timeline
    APICallResult home_timeline(string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/home_timeline.json", params)));
    }
    
    //GET statuses/retweets_of_me
    APICallResult retweets_of_me(string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/retweets_of_me.json", params)));
    }

    //GET statuses/retweets/:id
    APICallResult retweets(long id, string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/retweets/" ~ id.to!string ~ ".json", params)));
    }
    
    //GET statuses/show/:id
    APICallResult show(long id, string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/show/" ~ id.to!string ~ ".json", params)));
    }
    //POST statuses/destroy/:id
    APICallResult destroy(long id, string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("POST", "statuses/destroy/" ~ id.to!string ~ ".json", params)));
    }
    
    //POST statuses/update
    APICallResult update(string status, string[string] params = string[string].init){      
      if(status.length == 0 || status.removechars(" ").length == 0)
        return generateResult(false, JSONValue.init);

      params["status"] = status;

      return generateResult(true, parseJSON(request("POST", "statuses/update.json", params)));
    }
    
    //POST statuses/retweet/:id
    APICallResult retweet(long id, string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("POST", "statuses/retweet/" ~ id.to!string ~ ".json", params)));
    }

    //Todo: adapt to update with media
    //POST statuses/update_with_media
    APICallResult update_with_media(string status, ubyte[][] images, string filenames[], string[string] params = string[string].init){
      if(status.length == 0 || status.removechars(" ").length == 0)
        return generateResult(false, JSONValue.init);
      params["status"] = status;
      
      return callPostImage(images, filenames, params);
    }
    APICallResult update_with_media(string status, ubyte[] image, string filename, string[string] params = string[string].init){
      if(status.length == 0 || status.removechars(" ").length == 0)
        return generateResult(false, JSONValue.init);
      params["status"] = status;

      return callPostImage([image], [filename], params);
    }
    private APICallResult callPostImage(ubyte[][] images, string[] filenames, string[string] params){
      //return generateResult(true, parseJSON(postImage("https://api.twitter.com/1.1/statuses/update_with_media.json", images, filenames, params)));
      return generateResult(true, parseJSON(postImage("https://api.twitter.com/1.1/statuses/update_with_media.json", images, filenames, params)));
    }

    //GET statuses/oembed
    APICallResult oembed(in long id, string[string] params = string[string].init){
      params["id"] = id.to!string;
      return generateResult(true, parseJSON(request("GET", "statuses/oembed", params)));
    }

    //GET statuses/retweeters/ids
    APICallResult retweeters(long id, string[string] params = string[string].init){
      return generateResult(true, parseJSON(request("GET", "statuses/retweeters/" ~ id.to!string ~ ".json", params)));
    }

    //GET statuses/lookup
    APICallResult lookup(in long id, string[string] params = string[string].init){
      params["id"] = id.to!string;
      return generateResult(true, parseJSON(request("GET", "statuses/lookup.json", params)));
    }
  }

}
