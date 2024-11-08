using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using ToDoListAPI.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
if (builder.Environment.IsDevelopment())
{
  builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
      .AddMicrosoftIdentityWebApi(builder.Configuration);
}
else
{
  var azureAdConfig = new ConfigurationBuilder()
      .AddInMemoryCollection(new Dictionary<string, string?>
      {
            {"AzureAd:Instance", Environment.GetEnvironmentVariable("AZURE_AD_INSTANCE")},
            {"AzureAd:TenantId", Environment.GetEnvironmentVariable("AZURE_TENANT_ID")},
            {"AzureAd:ClientId", Environment.GetEnvironmentVariable("AZURE_CLIENT_ID")},
            {"AzureAd:Scopes", "{\"Read\": [ \"ToDoList.Read\", \"ToDoList.ReadWrite\"],\"Write\": [ \"ToDoList.ReadWrite\" ]}"},
            {"AzureAd:AppPermissions", "{\"Read\": [ \"ToDoList.Read.All\", \"ToDoList.ReadWrite.All\" ],\"Write\": [ \"ToDoList.ReadWrite.All\" ]}"}
      })
      .Build();

  builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
      .AddMicrosoftIdentityWebApi(azureAdConfig);
}

builder.Services.AddDbContext<ToDoContext>(opt =>
      opt.UseSqlServer(builder.Configuration.GetConnectionString("ToDos")));

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
  c.SwaggerDoc("v1", new OpenApiInfo { Title = "ToDo API", Version = "v1" });
  c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
  {
    Name = "Authorization",
    Type = SecuritySchemeType.Http,
    Scheme = "Bearer",
    BearerFormat = "JWT",
    In = ParameterLocation.Header,
    Description = "Enter 'Bearer' followed by your token"
  });
  c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "ToDo API v1"));
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
