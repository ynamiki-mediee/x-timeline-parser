# X(Twitter) Timeline Parser

A collection of scripts for retrieving and analyzing posts from X (formerly Twitter). It includes methods using the API as well as parsing HTML and text files.

## Setup

### Preparing the Development Environment

This project uses VS Code's DevContainer feature to easily set up the development environment.

#### Requirements

- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Remote - Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

#### Setting Up with DevContainer

1. Open the project folder in VS Code.
2. Click the green icon in the bottom-left corner.
3. From the menu, select "Reopen in Container."
4. The Docker container will be automatically built, and the necessary environment will be set up.

This will automatically create a development environment with Ruby 3.2 and all required libraries installed.

## Usage

### 1. Retrieving Posts Using the API (script.rb)

Retrieve posts from a specific user using the Twitter API.

1. Preparation:

   - Create an app in the Twitter Developer Portal and obtain API keys.
   - Set `CLIENT_ID`, `CLIENT_SECRET`, and `BEARER_TOKEN` in `script.rb`.

2. Execution:

   ```bash
   ruby src/script.rb
   ```

3. Parameter Configuration:
   - `USERNAME`: The target username (without @).
   - `MAX_RESULTS`: Maximum results per request (up to 100).
   - `MAX_REQUESTS`: Maximum number of requests.
   - `OUTPUT_FILE`: Output CSV file name.

### 2. Parsing Posts from an HTML File (x_parser.html.rb)

Parse posts from an HTML file saved from the browser.

1. Execution:

   ```bash
   ruby src/x_parser.html.rb input.html [output.csv]
   ```

   - `input.html`: The HTML file to parse.
   - `output.csv`: Output CSV file (optional, default is `x_conversation.csv`).

2. Output Format:
   - Username
   - Handle (@xxx)
   - Post time
   - Post content
   - Metrics (reply count, retweet count, like count, view count)

### 3. Parsing Posts from a Text File (x_parser.txt.rb)

Parse posts from text copied from X/Twitter.

1. Execution:

   ```bash
   ruby src/x_parser.txt.rb input.txt [output.csv]
   ```

   - `input.txt`: The text file to parse.
   - `output.csv`: Output CSV file (optional, default is `x_conversation.csv`).

2. Output Format:
   - Username
   - Handle (@xxx)
   - Post time
   - Post content
   - Metrics (numbers only)

## Notes

- When using the API, be mindful of Twitter's rate limits.
- HTML and text parsing may stop working if Twitter changes its structure.
- Ensure that the use of retrieved data complies with relevant laws and terms of service.
