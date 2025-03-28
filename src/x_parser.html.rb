require 'csv'
require 'nokogiri'

def extract_conversation(html_content)
  # Parse HTML
  doc = Nokogiri::HTML(html_content)

  # Array to store conversation data
  conversation = []

  # Get each post element
  tweets = doc.css('article[role="article"]')

  tweets.each do |tweet|
    # Username
    username = tweet.css('div[data-testid="User-Name"] span.css-1jxf684').first&.text&.strip
    next unless username # Skip if no username

    # Handle (@xxx)
    handle = tweet.css('div[dir="ltr"] span.css-1jxf684:contains("@")').first&.text&.strip

    # Time
    time_element = tweet.css('time')
    time = time_element.first&.text&.strip

    # Post content
    content = tweet.css('div[data-testid="tweetText"] span.css-1jxf684').map(&:text).join(' ').strip

    # Metrics (likes, retweets, etc.)
    metrics = {}

    # Reply count
    reply_count = tweet.css('div[data-testid="reply"] span.css-1jxf684').text.strip
    metrics['replies'] = reply_count unless reply_count.empty?

    # Retweet count
    retweet_count = tweet.css('div[data-testid="retweet"] span.css-1jxf684').text.strip
    metrics['retweets'] = retweet_count unless retweet_count.empty?

    # Like count
    like_count = tweet.css('div[data-testid="like"] span.css-1jxf684').text.strip
    metrics['likes'] = like_count unless like_count.empty?

    # View count
    view_count = tweet.css('a[href*="/analytics"] span.css-1jxf684').text.strip
    metrics['views'] = view_count unless view_count.empty?

    # Convert metrics to string
    metrics_str = metrics.map { |k, v| "#{k}: #{v}" }.join(', ')

    # Add to conversation array
    conversation << {
      username: username,
      handle: handle,
      time: time,
      content: content,
      metrics: metrics_str
    }
  end

  conversation
end

def save_to_csv(conversation, filename = "x_conversation.csv")
  CSV.open(filename, "w", encoding: "UTF-8") do |csv|
    # Header row
    csv << ["Username", "Handle", "Time", "Content", "Metrics"]

    # Data rows
    conversation.each do |post|
      csv << [
        post[:username],
        post[:handle],
        post[:time],
        post[:content],
        post[:metrics]
      ]
    end
  end

  puts "Conversation data saved to #{filename}."
end

# Main process
def main(input_file, output_file = "x_conversation.csv")
  begin
    # Read file
    html_content = File.read(input_file, encoding: 'UTF-8')

    # Extract conversation data
    conversation = extract_conversation(html_content)

    # If no data found
    if conversation.empty?
      puts "No conversation data found. The HTML structure may have changed."
      return
    end

    # Save to CSV
    save_to_csv(conversation, output_file)

    # Display preview
    puts "\nPreview of extracted conversation:"
    puts "=" * 80
    conversation.each_with_index do |post, index|
      puts "Post ##{index + 1}"
      puts "Username: #{post[:username]}"
      puts "Handle: #{post[:handle]}"
      puts "Time: #{post[:time]}"
      puts "Content: #{post[:content]}"
      puts "Metrics: #{post[:metrics]}"
      puts "-" * 80
    end

    puts "Total #{conversation.size} posts extracted."
  rescue => e
    puts "An error occurred: #{e.message}"
    puts e.backtrace
  end
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: ruby x_conversation_parser.rb input_filename [output_filename]"
    exit(1)
  end

  input_file = ARGV[0]
  output_file = ARGV[1] || "x_conversation.csv"

  main(input_file, output_file)
end