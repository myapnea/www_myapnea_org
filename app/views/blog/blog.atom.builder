# frozen_string_literal: true

atom_feed(root_url: "#{ENV["website_url"]}/blog") do |feed|
  feed.title("#{ENV["website_name"]} Blog")
  feed.updated @broadcasts.maximum(:publish_date)

  @broadcasts.each do |broadcast|
    feed.entry(broadcast,
               url: "#{ENV["website_url"]}/blog/#{broadcast.to_param}",
               published: broadcast.publish_date) do |entry|
      entry.title(broadcast.title)
      entry.content(simple_markdown(broadcast.description, allow_links: false, allow_images: false, allow_tables: false), type: "html")
      entry.summary broadcast.short_description
      entry.author do |author|
        author.name(broadcast.user.username)
      end
    end
  end
end
