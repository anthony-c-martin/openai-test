using System.Collections.Immutable;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Azure.AI.OpenAI;
using Azure.Identity;
using Azure;

namespace OpenAiTest.Controllers;

[ApiController]
public class ApiController : ControllerBase
{
    public record TestRequest(string ResourceType, string Scenario);

    public record TestResponse(string Json);

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

        var systemPromps = """
You write code as queried by the user. Only output code. Wrap the code like that:

```json
{code}
```

Put explanations directly in the code as comments.
""";

        var prompt = $"""
Generate JSON for an Aure resource body of type '{request.ResourceType}' to accomplish the following scenario: {request.Scenario}.
""";

        //https://www.windmill.dev/blog/windmill-ai
        var response = await client.GetChatCompletionsAsync(
            "chatmodel",
            new ChatCompletionsOptions(new ChatMessage[] {
                new(ChatRole.System, systemPromps),
                new(ChatRole.User, prompt),
            }));

        var choice = response.Value.Choices.First();

        Console.WriteLine(choice.Message.Content);
        var matches = Regex.Matches(choice.Message.Content, "```json\n(.*)\n```", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        return new(matches[0].Groups[1].Value);
    }
}

/*
Test scenarios

curl -X 'POST' \
  'http://localhost:3000/test' \
  -H 'accept: text/plain' \
  -H 'Content-Type: application/json' \
  -H 'x-apikey: localonlytestkey' \
  -d '{
  "resourceType": "Microsoft.Compute/virtualMachines",
  "scenario": "linux vm with 2 data disks attached"
}'

curl -X 'POST' \
  'http://localhost:3000/test' \
  -H 'accept: text/plain' \
  -H 'Content-Type: application/json' \
  -H 'x-apikey: localonlytestkey' \
  -d '{
  "resourceType": "Microsoft.Storage/storageAccounts",
  "scenario": "storage account for a static website, with hot storage enabled and zone redundancy"
}'
*/