import twitter4d;
import std.stdio,
       std.conv;

void main(){
  Twitter4D t4d = new Twitter4D([
      "consumerKey"       : "",
      "consumerSecret"    : "",
      "accessToken"       : "",
      "accessTokenSecret" : ""]);

  /*
    t4d.statuses.SomeMethods return type are APICallResult.
    That type were defined at TwitterAPI.d

    Notice:
      Maybe, I'll chenge the return type for more easy to use the value.


      The class of APICallResult has json value and accessor for it.
      The jsonvalue accessors are
        getJsonElem -> get element from APICallResult's jsonvalue,
        getJsonArrayElem -> get element from APICallResult's json array value,
        getJsonElemFromJsonValue -> get element from any JSONValue,
        getJsonArrayElemFromJsonValue -> get element from any JSONValue's array.
   */

  //POST statuses/update
  auto updateResult = t4d.statuses.update("Hello World! via t4d");
  writeln("your tweet's text -> ", updateResult.getJsonElem("text"));

  //GET statuses/[mentions/user/home]_timeline
  auto timelineResult = t4d.statuses.home_timeline(["count" : "30"]);
  foreach(statusJson; timelineResult.json.array)
    writeln(timelineResult.getJsonElemFromJsonValue(statusJson, "user/screen_name")
        ~ " : " ~ timelineResult.getJsonElemFromJsonValue(statusJson, "text"));

  //POST statuses/destroy
  t4d.statuses.destroy(updateResult.getJsonElem("id").to!long);
}
