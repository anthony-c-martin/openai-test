using System.Collections.Immutable;
using Microsoft.AspNetCore.Mvc;
using Bicep.Core.Emit;
using Bicep.Core;
using System.IO.Abstractions;
using Bicep.Decompiler;

namespace OpenAiTest.Controllers;

[ApiController]
public class ApiController : ControllerBase
{
    public record TestRequest(string Message);

    public record TestResponse(string Message);

    [HttpPost]
    [Route("test")]
    public async Task<TestResponse> Test(TestRequest request)
    {
        await Task.CompletedTask;

        return new(request.Message);
    }
}