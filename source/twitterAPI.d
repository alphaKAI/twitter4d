/*
  Twitter API wrapper.
  Using my Twitter API Core Wrapper -Twitter4D-

  The MIT License

  Copyright (C) 2014 alphaKAI http://alpha-kai-net.info
 */
import std.string;
import twitter4d;
mixin template TwitterAPI(){
  class Statuses{
    auto update(string status, string[string] otherPrams = ["":""]){
      string[string] params;

      if(otherPrams != ["":""])
        foreach(key, value; otherPrams)
          params[key] = value;
      
      if((){
          if(status.length == 0)
            return true;
          if(status.removechars(" ").length == 0)
            return true;
          }())
        return "Error";

      params["status"] = status;

      return request("POST", "statuses/update.json", params);
    }
  }
}
