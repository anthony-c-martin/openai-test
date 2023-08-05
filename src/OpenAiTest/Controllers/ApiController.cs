using System.Collections.Immutable;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.OpenAI;
using Azure.Identity;
using Azure;

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
        var openAiEndpoint = Environment.GetEnvironmentVariable("OPENAI_ENDPOINT")
            ?? throw new InvalidOperationException("OPENAI_ENDPOINT not set");
        var openAiKey = Environment.GetEnvironmentVariable("OPENAI_KEY");

        var client = openAiKey is not null ?
            new OpenAIClient(new(openAiEndpoint), new AzureKeyCredential(openAiKey)) :
            new OpenAIClient(new(openAiEndpoint), new DefaultAzureCredential());

        //https://www.windmill.dev/blog/windmill-ai
        var response = await client.GetCompletionsAsync(
            "chatmodel",
            request.Message);

        var choice = response.Value.Choices.First();
        return new(choice.Text);
    }
}