require 'csv'

def extract_conversation(text)
  # Initialize array to store conversation data
  conversation = []

  # Split input by multiple newlines to separate posts
  posts = text.split(/\n{2,}/).reject(&:empty?)

  posts.each do |post|
    # Extract username
    username = post.match(/^(.+?)\n@/).to_a[1]&.strip

    # Extract handle
    handle = post.match(/@([^\n·]+)/).to_a[1]&.strip

    # Extract time
    time = post.match(/·\s*([^·\n]+)/).to_a[1]&.strip

    # Extract content (the main text of the post)
    content = if post.include?("\n")
                lines = post.split("\n")[2..-1] || []
                content_text = lines.join(" ").strip
                # Remove view counts and other metrics
                content_text.gsub(/\d+,?\d*(\s?(万|件の表示))?$/, "").strip
              else
                ""
              end

    # Extract metrics (likes, retweets, etc.)
    metrics = post.scan(/\d+,?\d*(\s?万)?/).join(", ")

    # Skip if no username found (likely not a post)
    next unless username

    # Add to conversation array
    conversation << {
      username: username,
      handle: handle,
      time: time,
      content: content,
      metrics: metrics
    }
  end

  conversation
end

def save_to_csv(conversation, filename = "x_conversation.csv")
  CSV.open(filename, "w", encoding: "UTF-8") do |csv|
    # Write header
    csv << ["Username", "Handle", "Time", "Content", "Metrics"]

    # Write data rows
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

  puts "Conversation saved to #{filename}"
end

# Read text from file
def read_text_file(filepath)
  begin
    File.read(filepath, encoding: 'UTF-8')
  rescue => e
    puts "Error: Failed to read file - #{e.message}"
    exit(1)
  end
end

# Main process
if ARGV.empty?
  puts "Usage: ruby x_conversation_parser.rb input_filename [output_filename]"
  exit(1)
end

input_file = ARGV[0]
output_file = ARGV[1] || "x_conversation.csv"

# Read text file
text = read_text_file(input_file)

# Extract conversation data
conversation = extract_conversation(text)

# Save to CSV
save_to_csv(conversation, output_file)

# Display data preview
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