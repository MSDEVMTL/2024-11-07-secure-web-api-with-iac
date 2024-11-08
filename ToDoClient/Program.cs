using Microsoft.Identity.Client;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using ToDoClient.Models;


HttpClient client = new HttpClient();

var clientId = "TODO:FILL";
var clientSecret = "TODO:FILL";
var scopes = new[] { "api://1c43dc76-9f14-4651-a2f7-68f25d43bb9d/.default" };
var tenantName = "TODO:FILL";
var authority = $"https://TODO:FILL/";

var app = ConfidentialClientApplicationBuilder
    .Create(clientId)
    .WithAuthority(authority)
    .WithClientSecret(clientSecret)
    .Build();

var result = await app.AcquireTokenForClient(scopes).ExecuteAsync();

client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);

var newToDo = new
{
    id = 0,
    owner = "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    description = "My Todo"
};

//var responsePost = await client.PostAsJsonAsync("https://localhost:7285/api/ToDoList", newToDo);
var responsePost = await client.PostAsJsonAsync("https://webapi-todoapi-dev.azurewebsites.net/api/ToDoList", newToDo);
Console.WriteLine("Your response is: " + responsePost.StatusCode);

//var ToDos = await client.GetFromJsonAsync<ToDo[]>("https://localhost:7285/api/ToDoList");
var ToDos = await client.GetFromJsonAsync<ToDo[]>("https://webapi-todoapi-dev.azurewebsites.net/api/ToDoList");
Console.WriteLine(ToDos?.Length);




//var ToDos = await client.GetStringAsync("https://localhost:7285/api/ToDoList");
//var responseGet = await client.GetAsync("https://localhost:7285/api/ToDoList");
//var contents = await responseGet.Content.ReadAsStringAsync();
//Console.WriteLine(contents);
//Console.WriteLine("Your response is: " + responseGet.StatusCode);
