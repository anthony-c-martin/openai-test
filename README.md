# openai-test
This is a demo of using OpenAI on Azure. The build & deployment process is fully automated via GitHub Actions.

## Running locally
1. Open in Codespaces
1. Build: 
    ```sh
    docker build -t service:latest ./src
    ```
1. Run: 
    ```sh
    docker run -p 8001:80 service:latest ./src
    ```
1. Test locally:
    * Build:
        ```sh
        curl -X POST http://localhost:8001/test \
          -H 'Content-Type: application/json' \
          -d '{"message": "Hello world!"}'