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

