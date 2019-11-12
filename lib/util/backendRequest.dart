import 'dart:convert';
import 'package:cookmate/cookbook.dart';
import 'package:http/http.dart' as http;

class BackendRequest {

  static const int _INFORMATIONAL = 1;
  static const int _SUCCESS = 2;
  static const int _REDIRECT = 3;
  static const int _CLIENT = 4;
  static const int _SERVER = 5;

  static const String _FAIL_LOGIN = "Unable to log in with provided credentials.";

  /* Method: createUser
   * Arg(s):
   *    - email: the user's email
   *    - username: the user's username
   *    - password: the user's password
   * 
   * Return:
   *    - success: ID of the new user
   *    - failure: null
   * 
   * Notes: This method does not do any validation except checking if a username
   *        is unique or not. All other validation must be done beforehand.
   */
  static Future<int> createUser (String email, String username, String password) async {

    print("Creating new user...");
      
    // Make API call
    final response = await http.post(
      "https://thecookmate.com/auth/users/", 
      body: {
        "email":email,
        "username":username,
        "password":password
      }
    );

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    var data = jsonDecode(response.body);
    print("User successfully created with ID ${data["id"]}");
    return data["id"];
  }

  /* Method: getUser
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   * 
   * Return:
   *    - success: ID of the new user
   *    - failure: null
   */
  static Future<int> getUser (String authToken) async {

    print("Getting user info ($authToken)...");
      
    // Make API call
    final response = await http.get(
      "https://thecookmate.com/auth/users/me", 
      headers: { "Authorization":"Token $authToken" }
    );

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    var data = jsonDecode(response.body);
    print("User found, returning user ID ${data["id"]}");
    return data["id"];
  }

  /* Method: deleteUser
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   *    - password: the user's password
   * 
   * Return:
   *    - success: true
   *    - failure: false
   */
  static Future<bool> deleteUser (String authToken, String password) async {

    print("Deleting user ($authToken, $password)...");

    // Make API call
    final client = http.Client();
    var rq = http.Request("DELETE", Uri.parse("https://thecookmate.com/auth/users/me/"));
    rq.bodyFields = {"current_password":password};
    rq.headers.addAll({"Authorization":"Token $authToken"});
    var response = await client.send(rq);
    client.close();

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print(_interpretStatus(statusCode, response.statusCode, await response.stream.bytesToString()));
      return false;
    }

    print("User deletion successful");
    return true;
  }

  /* Method: updateUser
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   *    - currentUsername (optional): The user's current username
   *    - currentPassword (optional): The user's current password
   *    - newUsername (optional): The user's requested new username
   *    - newPassword (optional): The user's requested new password
   * 
   * Return:
   *    - success: true, if ALL requested updates are successful
   *    - failure: false, if ANY of the requested updates fail
   * 
   * Notes: To update the username, both currentUsername and currentPassword 
   *        need to be supplied, and correct. Same for passwords.
   */
  static Future<bool> updateUser (String authToken, {String currentUsername, String currentPassword, String newUsername, String newPassword}) async {

    bool updateStatus = true;
    
    // Update username
    if(currentUsername != null && newUsername != null)
    {
      print("Updating username from $currentUsername to $newUsername...");
      
      // Make API call
      final response = await http.post(
        "https://thecookmate.com/auth/users/set_username/", 
        headers: { "Authorization":"Token $authToken" },
        body: {"new_username":newUsername, "current_username":currentUsername}
      );

      // Validate return
      int statusCode = response.statusCode ~/ 100;
      if(statusCode != _SUCCESS)
      {
        print(_interpretStatus(statusCode, response.statusCode, response.body));
        updateStatus = false;
      } else {
        print("Username successfully updated to $newUsername");
      }
    }

    // Update password
    if(currentPassword != null && newPassword != null)
    {
      print("Updating password from $currentPassword to $newPassword...");
      
      // Make API call
      final response = await http.post(
        "https://thecookmate.com/auth/users/set_password/", 
        headers: { "Authorization":"Token $authToken" },
        body: {"new_password":newPassword, "current_password":currentPassword}
      );

      // Validate return
      int statusCode = response.statusCode ~/ 100;
      if(statusCode != _SUCCESS)
      {
        print(_interpretStatus(statusCode, response.statusCode, response.body));
        updateStatus = false;
      } else {
        print("Password successfully updated to $newPassword");
      }
    }

    return updateStatus;
  }

  /* Method: login
   * Arg(s):
   *    - username: the user's username
   *    - password: the user's password
   * 
   * Return:
   *    - success: the auth token
   *    - failure: the error message
   */
  static Future<String> login (String username, String password) async {

    print("Logging in ($username, $password)...");
      
    // Make API call
    final response = await http.post(
      "https://thecookmate.com/auth/token/login", 
      body: {
        "username":username,
        "password":password
      }
    );

    // Validate return
    var data = jsonDecode(response.body);
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      List<dynamic> loginError = data["non_field_errors"];
      if(loginError != null && loginError[0] == _FAIL_LOGIN) {
        print("Log in failed, invalid credentials");
        return loginError[0];
      }

      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    print("Log in successful, with token ${data["auth_token"]}");
    return data["auth_token"];
  }

  /* Method: logout
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   * 
   * Return:
   *    - success: true
   *    - failure: false
   */
  static Future<bool> logout (String authToken) async {

    print("Logging out ($authToken)...");
      
    // Make API call
    final response = await http.post(
      "https://thecookmate.com/auth/token/logout", 
      headers: { "Authorization":"Token $authToken" }
    );

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return false;
    }

    print("Log out successful");
    return true;
  }

  /* Method: ingredientList
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   * 
   * Return:
   *    - success: A list of ingredients
   *    - failure: null
   */
  static Future<List<Ingredient>> ingredientList (String authToken) async {

    print("Getting ingredient list...");

    // Make API call
    final response = await http.get(
      "https://thecookmate.com/api/recipe/ingredient", 
      headers: { "Authorization":"Token $authToken" }
    );

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print("Request for ingredient list failed");
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    // Parse JSON & build ingredient list
    List<dynamic> data = jsonDecode(response.body);
    List<Ingredient> ingredients = new List<Ingredient>();
    Ingredient ingredient;
    for(int i = 0; i < data.length; i++)
    {
      ingredient = Ingredient.fromJSON(data[i]);
      ingredients.add(ingredient);
    }

    return ingredients;
  }

  /* Method: getDiets
   * Arg(s):
   *    - authToken: The auth token associated with the user when they log in
   * 
   * Return:
   *    - success: A list of diets
   *    - failure: null
   */
  static Future<List<Diet>> getDietList (String authToken) async {

    print("Getting full list of diets...");

    // Make API call
    final response = await http.get(
      "https://thecookmate.com/api/recipe/diets", 
      headers: { "Authorization":"Token $authToken" }
    );

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print("Request for diet list failed");
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    // Parse JSON & build ingredient list
    List<dynamic> data = jsonDecode(response.body);
    List<Diet> diets = new List<Diet>();
    Diet diet;
    for(int i = 0; i < data.length; i++)
    {
      diet = Diet.fromJSON(data[i]);
      diets.add(diet);
    }

    return diets;
  }

  /* Method: barcode
   * Arg(s):
   *    - barcode: The UPC of the item scanned
   *    - authToken: The auth token associated with the user when they log in
   * 
   * Return:
   *    - success: A list of breadcrumbs
   *    - failure: null
   */
  static Future<List<String>> barcode (String barcode, String authToken) async {

    print("Getting ingredient breadcrumbs from barcode...");

    // Make API call
    var params = { "barcode":barcode };
    final uri = Uri.https("thecookmate.com", "/api/barcode/", params);
    final response = await http.get(uri, headers: { "Authorization":"Token $authToken" });

    // Validate return
    int statusCode = response.statusCode ~/ 100;
    if(statusCode != _SUCCESS)
    {
      print("Request for ingredient failed");
      print(_interpretStatus(statusCode, response.statusCode, response.body));
      return null;
    }

    // Parse JSON & build ingredient list
    var data = jsonDecode(response.body);
    List<dynamic> dataValues = data['label'];
    List<String> breadcrumbs = new List(dataValues.length);
    for(int i = 0; i < dataValues.length; i++)
    {
      print("Breadcrumb ${i + 1}: ${dataValues[i].toString()}");
      breadcrumbs[i] = dataValues[i].toString();
    }

    return breadcrumbs;
  }

  /* Method: _interpretStatus
   * Arg(s):
   *    - statusSode: The reduced code to determine error type
   *    - responseCode: The actual status code produced by the response
   * 
   * Return: the appropriate status notification/error message
   */
  static String _interpretStatus (int statusCode, int responseCode, String error) {

    String statusReport = "\n\n\t--- Backend Request Failed ---\n\tStatus code $responseCode\n"; 

    switch(statusCode)
    {
      case _INFORMATIONAL:
        statusReport = "\n\n\t--- Backend Request In Progress ---\n\tStatus code $statusCode, "; 
        break;
      case _REDIRECT:
        statusReport += "\tRedirect Error";
        break;
      case _CLIENT:
        statusReport += "\tClient Error";
        break;
      case _SERVER:
        statusReport += "\tServer Error";
        break;
    }

    var message = jsonDecode(error);
    statusReport += ": ${message['error']}";
    return statusReport;
  }
}