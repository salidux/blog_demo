# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Rails 7.2 blog application built as a Heroku deployment demo. Its defining feature is **asynchronous post-analytics processing** via Delayed Job backed by the database — viewing a post enqueues a background job that tracks view counts and computes reading time.

## Commands

```bash
bundle install                        # Install gems (Ruby 3.3.7)
bin/rails db:create db:migrate db:seed # Set up the database
bin/rails server                      # Start the web server (http://localhost:3000)
bin/delayed_job start                 # Run the background worker (separate terminal, dev)
bin/rails jobs:work                   # Alternative foreground worker (used in production Procfile)

# Tests
bin/rails db:test:prepare             # Prepare test DB (run before tests if schema changed)
bin/rails test                        # Run unit/controller/job tests
bin/rails test test/jobs/post_analytics_processor_job_test.rb   # Single file
bin/rails test test/jobs/post_analytics_processor_job_test.rb:12 # Single test by line
bin/rails test:system                 # System tests (Capybara + Selenium/Chrome)

# Lint & security (these run in CI — match them before pushing)
bin/rubocop                           # rubocop-rails-omakase style
bin/brakeman --no-pager               # Rails security scan
bin/importmap audit                   # JS dependency vulnerability scan
```

CI (`.github/workflows/ci.yml`) runs brakeman, importmap audit, rubocop, and `bin/rails db:test:prepare test test:system` on every PR and push to `main`.

## Architecture

**Databases differ by environment**: SQLite3 in development/test (`storage/*.sqlite3`), PostgreSQL in production (via `DATABASE_URL`). See `config/database.yml`.

**Background jobs use ActiveJob with the `:delayed_job` adapter** (configured in `config/environments/{development,production}.rb`). Jobs are persisted in the `delayed_jobs` table, so a worker process must be running for jobs to execute. The analytics flow:

1. `PostsController#show` calls `PostAnalyticsProcessorJob.perform_later(@post.id)` on every post view — this is the only trigger.
2. `PostAnalyticsProcessorJob` (`app/jobs/`) finds or creates the post's `PostAnalytics`, increments `view_count`, and recomputes `reading_time` (word count ÷ 200 wpm, minimum 1 minute).
3. `StatsController#index` reads aggregated stats with a raw `LEFT JOIN` against `post_analytics`, using `COALESCE` so posts with no analytics yet show zeros.

**Data model**: `Post has_one :post_analytics` (dependent: destroy). Analytics live in a separate table rather than columns on `posts`, so they are written only by the worker and never block a request.

## Deployment (Heroku)

Process types are defined in `Procfile`:
- `release: bundle exec rails db:migrate db:seed` — runs automatically before each deploy.
- `web:` — Puma.
- `worker: bundle exec rake jobs:work` — the Delayed Job worker; must be scaled up (`heroku ps:scale worker=1`) or analytics jobs never run.

`backup_Procfile` is an unused copy. The README has detailed Heroku deployment steps.
