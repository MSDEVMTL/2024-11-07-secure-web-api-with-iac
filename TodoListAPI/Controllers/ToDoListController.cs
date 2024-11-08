using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.Resource;
using ToDoListAPI.Models;
using ToDoListAPI.Context;

namespace ToDoListAPI.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class ToDoListController : ControllerBase
{
    private readonly ToDoContext _toDoContext;

    public ToDoListController(ToDoContext toDoContext)
    {
        _toDoContext = toDoContext;
    }

    [HttpGet]
    [RequiredScopeOrAppPermission(
        RequiredScopesConfigurationKey = "AzureAD:Scopes:Read",
        RequiredAppPermissionsConfigurationKey = "AzureAD:AppPermissions:Read"
    )]
    public async Task<IActionResult> GetAsync()
    {
        var toDos = await _toDoContext.ToDos!
            .Where(td => td.Owner == GetUserId())
            .ToListAsync();

        return Ok(toDos);
    }

    [HttpPost]
    [RequiredScopeOrAppPermission(
        RequiredScopesConfigurationKey = "AzureAD:Scopes:Write",
        RequiredAppPermissionsConfigurationKey = "AzureAD:AppPermissions:Write"
    )]
    public async Task<IActionResult> PostAsync([FromBody] ToDo toDo)
    {
        var newToDo = new ToDo()
        {
            Owner = GetUserId(),
            Description = toDo.Description
        };

        await _toDoContext.ToDos!.AddAsync(newToDo);
        await _toDoContext.SaveChangesAsync();

        return Created($"/todo/{newToDo!.Id}", newToDo);
    }

    private Guid GetUserId()
    {
        Guid userId;
        if (!Guid.TryParse(HttpContext.User.GetObjectId(), out userId))
        {
            throw new Exception("User ID is not valid.");
        }
        return userId;
    }
}