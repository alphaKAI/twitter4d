import twitter4d;
import std.stdio,
       std.json,
       std.conv,
       std.regex;
void main(){
  Twitter4D t4d = new Twitter4D([
      "consumerKey"       : "Your Consumer Key",
      "consumerSecret"    : "Your Consumer Secret",
      "accessToken"       : "Your Access Token" ,
      "accessTokenSecret" : "Your Access Token Secret"]);
  /**
    Twitter4D provide another way(to create instance)
    Twitter4D t4d = new Twitter4D(
      "your consumerkey",
      "your consumerSecret",
      "your accessToken",
      "your accesstokensecret");
   */

  writeln(t4d.request("POST", "statuses/update.json", ["status" : "test"]));
  writeln(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["":""])));
  
  foreach(line; t4d.stream()){
    if(match(line.to!string, regex(r"\{.*\}"))){
      auto parsed = parseJSON(line.to!string);
      if("text" in parsed.object)//tweet
        writefln("\r[%s]:%s - [%s]", parsed.object["user"].object["name"],
            parsed["created_at"],
            parsed.object["text"]);
      }
    }

}
