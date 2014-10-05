/*
  Twitter API wrapper.
  Using my Twitter API Core Wrapper -Twitter4D-

  The MIT License

  Copyright (C) 2014 alphaKAI http://alpha-kai-net.info
 */
<<<<<<< HEAD
import std.string;
=======
public import std.string;
public import std.json;
>>>>>>> 5cb46df... bp
import twitter4d;
mixin template TwitterAPI(){
  struct APICallResult{
    bool success;
    JSONValue json;

    string getJsonData(string path){
      JSONValue tmp = json;
      
      foreach(key; path.split("/"))
        tmp = tmp.object[key.to!string];
      
      return tmp.to!string;
    }
  }

  private APICallResult generateResult(bool status, JSONValue jsonData){
    APICallResult result;

    result.success = status;
    result.json    = jsonData;

    return result;
  }

  class Statuses{
    //GET statuses/mentions_timeline
    APICallResult mentionsTimeline(string[string] otherParams = ["":""]){
    	
    	}
    //GET statuses/user_timeline
    //GET statuses/home_timeline
    //GET statuses/retweets_of_me

    APICallResult update(string status, string[string] otherParams = ["":""]){
      string[string] params;

      if(otherParams != ["":""])
        foreach(key, value; otherParams)
          params[key] = value;
      
<<<<<<< HEAD
/*      if((){
          if(status.length == 0)
            return true;
          }())*/
      /*
        Todo : change the return type
       */
      if(status.length == 0)
        throw new Error("Error");
=======
      if(status.length == 0 || status.removechars(" ").length == 0)
        return generateResult(false, JSONValue.init);
>>>>>>> 5cb46df... bp

      params["status"] = status;

      return generateResult(true, parseJSON(request("POST", "statuses/update.json", params)));
    }
  }

}
