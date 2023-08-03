using System.Collections.Immutable;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.OpenAI;
using Azure.Identity;

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
        var client = new OpenAIClient(new("OPENAPI_ENDPOINT"), new DefaultAzureCredential());

        /*
        TODO uncomment once auth has been set up!
        var response = await client.GetCompletionsAsync(
            "gpt-3.5-turbo",
            request.Message);

        foreach (var choice in response.Value.Choices)
        {
            return new(choice.Text);
        }
        */

        throw new InvalidOperationException("Failed to get OpenAI response");
    }
}