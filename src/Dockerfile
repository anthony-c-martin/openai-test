FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /app
COPY ./OpenAiTest .
RUN dotnet build OpenAiTest.csproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app
COPY --from=build /out ./
ENTRYPOINT ["dotnet", "OpenAiTest.dll"]