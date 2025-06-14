# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data in development/test
if Rails.env.development? || Rails.env.test?
  PostAnalytics.destroy_all
  Post.destroy_all
end

# Create sample blog posts
posts = [
  {
    title: "Getting Started with Ruby on Rails",
    content: "Ruby on Rails is a powerful web application framework that follows the convention over configuration principle. " +
             "In this comprehensive guide, we'll explore the fundamentals of Rails development, from setting up your first project " +
             "to deploying it to production. Rails provides a rich set of tools and conventions that make web development faster " +
             "and more enjoyable. We'll cover models, views, controllers, routing, database migrations, and much more. " +
             "By the end of this tutorial, you'll have a solid understanding of how to build robust web applications with Rails.",
    published: true
  },
  {
    title: "Understanding Background Jobs with Delayed Job",
    content: "Background jobs are essential for handling time-consuming tasks without blocking the user interface. " +
             "Delayed Job is a popular Ruby gem that provides a simple way to run jobs asynchronously. " +
             "In this article, we'll learn how to set up Delayed Job with ActiveRecord, create custom jobs, " +
             "and monitor job execution. We'll also explore best practices for error handling and job retry logic.",
    published: true
  },
  {
    title: "Deploying Rails Apps to Heroku",
    content: "Heroku is one of the most popular platforms for deploying Rails applications. " +
             "This step-by-step guide will walk you through the entire deployment process, from preparing your app " +
             "to configuring environment variables and setting up a PostgreSQL database. " +
             "We'll also cover how to manage different environments and troubleshoot common deployment issues.",
    published: true
  },
  {
    title: "Advanced Rails Testing Strategies",
    content: "Testing is a crucial part of Rails development. In this article, we'll explore advanced testing techniques " +
             "including model testing, controller testing, integration testing, and system testing. " +
             "We'll learn how to use fixtures, factories, and mocks effectively to create maintainable test suites.",
    published: false
  }
]

created_posts = posts.map do |post_data|
  Post.create!(post_data)
end

# Create analytics data for published posts
created_posts.select(&:published?).each_with_index do |post, index|
  # Create varying levels of analytics data
  view_count = case index
  when 0 then 45  # Most popular post
  when 1 then 23  # Medium popularity
  when 2 then 12  # Lower popularity
  else 5
  end

  # Calculate reading time based on actual content
  word_count = post.content.split.length
  reading_time = [ 1, (word_count / 200.0).ceil ].max

  post.create_post_analytics!(
    view_count: view_count,
    reading_time: reading_time,
    last_viewed_at: rand(1..7).days.ago
  )
end

puts "Created #{created_posts.length} posts with analytics data"
puts "Published posts: #{created_posts.count(&:published?)}"
puts "Draft posts: #{created_posts.count { |p| !p.published? }}"
