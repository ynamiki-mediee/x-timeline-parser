require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'time'
require 'oauth2'

# Set API keys (replace with actual keys)
CLIENT_ID = ''
CLIENT_SECRET = ''
BEARER_TOKEN = ''

# Configuration parameters
USERNAME = 'unarikun_narita'  # Username (without @)
MAX_RESULTS = 5     # Maximum results per request (up to 100)
MAX_REQUESTS = 2     # Total request limit (15 requests for up to 1500 posts)
OUTPUT_FILE = "#{USERNAME}_posts.csv"

# API endpoint
BASE_URL = 'https://api.twitter.com/2'

# Function to get user ID
def get_user_id(username)
  url = URI("#{BASE_URL}/users/by/username/#{username}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Authorization"] = "Bearer #{BEARER_TOKEN}"

  response = http.request(request)

  if response.code == '200'
    data = JSON.parse(response.body)
    return data['data']['id']
  else
    puts "Error: Failed to retrieve user information."
    puts "Status code: #{response.code}"
    puts "Response: #{response.body}"
    exit 1
  end
end

# Function to get user posts
def get_user_posts(user_id, pagination_token = nil)
  # Set query parameters
  params = {
    'max_results' => MAX_RESULTS,
    'tweet.fields' => 'created_at,public_metrics,text,author_id',
    'expansions' => 'author_id',
    'user.fields' => 'name,username'
  }

  # Add pagination token if available
  params['pagination_token'] = pagination_token if pagination_token

  # Add query parameters to URL
  query_string = URI.encode_www_form(params)
  url = URI("#{BASE_URL}/users/#{user_id}/tweets?#{query_string}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Authorization"] = "Bearer #{BEARER_TOKEN}"

  retry_count = 0
  max_retries = 3
  begin
    # Make HTTP request
    response = http.request(request)
  rescue => e
    if retry_count < max_retries && e.response&.status == 429
      wait_time = 2 ** retry_count * 30  # Exponential backoff (30s, 60s, 120s...)
      puts "Rate limit reached. Retrying in #{wait_time} seconds..."
      sleep wait_time
      retry_count += 1
      retry
    else
      raise e
    end
  end

  if response.code == '200'
    # Parse and return response data
    return JSON.parse(response.body)
  else
    puts "Error: Failed to retrieve posts."
    puts "Status code: #{response.code}"
    puts "Response: #{response.body}"
    return nil
  end
end

# Function to save posts to CSV
def save_to_csv(posts, filename)
  CSV.open(filename, 'w', force_quotes: true) do |csv|
    # Header row
    csv << ['ID', 'Text', 'Created At', 'Retweet Count', 'Like Count', 'Quote Count', 'Reply Count']

    # Data rows
    posts.each do |post|
      csv << [
        post['id'],
        post['text'],
        post['created_at'],
        post['public_metrics']['retweet_count'],
        post['public_metrics']['like_count'],
        post['public_metrics']['quote_count'],
        post['public_metrics']['reply_count']
      ]
    end
  end

  puts "#{posts.length} posts saved to #{filename}."
end

# Main process
begin
  puts "Fetching posts for '#{USERNAME}'..."

  # Get user ID
  user_id = get_user_id(USERNAME)
  puts "User ID: #{user_id}"

  all_posts = []
  pagination_token = nil
  request_count = 0

  # Fetch posts (using pagination)
  loop do
    sleep(1)  # Wait 1 second to avoid API rate limits
    request_count += 1
    puts "Executing request #{request_count}/#{MAX_REQUESTS}..."

    response_data = get_user_posts(user_id, pagination_token)
    break if response_data.nil? || !response_data['data']

    # Add fetched posts
    all_posts += response_data['data']
    puts "Currently fetched #{all_posts.length} posts."

    # Check for next page
    if response_data['meta'] && response_data['meta']['next_token'] && request_count < MAX_REQUESTS
      pagination_token = response_data['meta']['next_token']
    else
      break
    end
  end

  # Save results to CSV
  save_to_csv(all_posts, OUTPUT_FILE)

rescue => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace.join("\n")
end