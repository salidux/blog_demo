# Blog Demo - Rails Application with Background Jobs

A simple blog application built with Ruby on Rails that demonstrates background job processing using Delayed Job. This project showcases post analytics processing with real-time view tracking, reading time calculation, and comprehensive statistics.

## 🚀 Features

### Core Functionality
- **Blog Posts Management** - Create, read, update, and delete blog posts
- **Draft/Published States** - Manage post visibility and publication status
- **Responsive Design** - Modern, mobile-friendly user interface

### Analytics & Background Processing
- **Real-time View Tracking** - Automatically count post views using background jobs
- **Reading Time Calculation** - Estimate reading time based on content length (~200 words/minute)
- **Analytics Dashboard** - Comprehensive stats page showing post performance
- **Background Job Processing** - Non-blocking analytics processing with Delayed Job
- **PostgreSQL Persistence** - Jobs stored in database for reliability

### User Interface
- **Clean Navigation** - Footer navigation between Posts and Stats
- **Analytics Table** - Detailed view of post performance metrics
- **Summary Cards** - Total posts, views, and average reading time
- **Status Indicators** - Visual published/draft status indicators

## 🛠️ Technology Stack

- **Ruby on Rails 7.2+** - Web application framework
- **PostgreSQL** - Database (production) / SQLite3 (development)
- **Delayed Job** - Background job processing
- **Turbo & Stimulus** - Hotwire for enhanced user interactions
- **CSS3** - Custom responsive styling

## 📊 How It Works

1. **Post View** - When a user visits a blog post, a background job is enqueued
2. **Background Processing** - Delayed Job worker processes the analytics asynchronously
3. **Data Updates** - View count increments, reading time calculates, timestamp updates
4. **Stats Display** - Analytics dashboard shows real-time statistics

## 🏃‍♂️ Local Development

### Prerequisites
- Ruby 3.3+
- Rails 7.2+
- PostgreSQL (for production-like setup)
- SQLite3 (for development)

### Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd blog_demo

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the Rails server
rails server

# Start the background job worker (in another terminal)
./bin/delayed_job start
```

Visit `http://localhost:3000` to see the application.

## 🚀 Deploying to Heroku

### Prerequisites
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed
- Heroku account created
- Git repository initialized

### Step-by-Step Deployment

#### 1. Create Heroku Application
```bash
# Login to Heroku
heroku login

# Create new Heroku app (replace 'your-app-name' with desired name)
heroku create your-app-name

# Or create without specifying name (Heroku will generate one)
heroku create
```

#### 2. Configure Database
```bash
# Add PostgreSQL addon (free tier)
heroku addons:create heroku-postgresql:essential-0

# Verify database was added
heroku config
```

#### 3. Set Environment Variables
```bash
# Set Rails master key (if using credentials)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Set Rails environment
heroku config:set RAILS_ENV=production
heroku config:set RACK_ENV=production
```

#### 4. Automatic Database Migrations
The `Procfile` includes a `release` command that automatically runs database migrations before each deployment:

```
release: bundle exec rails db:migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
```

**Important**: Heroku runs the release command before starting your application, ensuring your database is always up-to-date with the latest migrations. This happens automatically - no manual intervention required!

#### 5. Deploy Application
```bash
# Add and commit all changes
git add .
git commit -m "Prepare for Heroku deployment"

# Push to Heroku (migrations will run automatically via release command)
git push heroku main

# Seed the database with sample data (optional, for demo purposes)
heroku run rails db:seed
```

#### 6. Scale Worker Dynos
```bash
# Enable worker dyno for background jobs (free tier allows 1 worker)
heroku ps:scale worker=1

# Check dyno status
heroku ps
```

#### 7. Open Application
```bash
# Open your deployed app
heroku open

# Or get the URL
heroku info
```

### 🔄 Heroku Deployment Process

When you push to Heroku, the following happens automatically:

1. **Build Phase** - Dependencies are installed
2. **Release Phase** - `bundle exec rails db:migrate` runs automatically
3. **Deploy Phase** - New version goes live with updated database schema
4. **Scale Phase** - Web and worker dynos start

This ensures your database is always properly migrated before the new code goes live!

### Monitoring & Debugging

```bash
# View application logs
heroku logs --tail

# Check release command logs (to see migration output)
heroku logs --source=release --tail

# Check background job status
heroku run rails console
# In console: Delayed::Job.count

# Monitor worker dyno
heroku logs --source=worker --tail

# Check database
heroku pg:info
```

### Scaling (If Needed)
```bash
# Scale web dynos
heroku ps:scale web=2

# Scale worker dynos
heroku ps:scale worker=2
```

## 📝 Demo Script

Perfect for demonstrating Rails + Heroku capabilities:

1. **Show the main blog page** - Display published posts
2. **Create a new post** - Demonstrate CRUD operations
3. **View a post** - Show how background jobs are triggered
4. **Navigate to Stats** - Display real-time analytics
5. **Explain background processing** - Show job queue and processing
6. **Demonstrate persistence** - Refresh page to show updated stats

## 🧪 Running Tests

```bash
# Run all tests
rails test

# Run specific test files
rails test test/jobs/post_analytics_processor_job_test.rb
rails test test/controllers/stats_controller_test.rb
```

## 📦 Project Structure

```
app/
├── controllers/          # PostsController, StatsController
├── jobs/                # PostAnalyticsProcessorJob
├── models/              # Post, PostAnalytics
└── views/               # Templates for posts and stats

db/
├── migrate/             # Database migrations
└── seeds.rb            # Sample data

test/                   # Comprehensive test suite
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is built for educational and demonstration purposes.

---

**Built with ❤️ using Ruby on Rails and Heroku**
