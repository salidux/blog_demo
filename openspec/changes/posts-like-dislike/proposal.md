## Why

Readers can view posts but have no way to signal whether they liked them, and authors have no lightweight measure of sentiment beyond raw view counts. Adding like/dislike buttons gives a simple, immediate engagement signal without requiring accounts or any client-side JavaScript.

## What Changes

- Add **like** and **dislike** buttons to the post show page, rendered as plain server-side form submissions (no JavaScript).
- Add `like_count` and `dislike_count` to the existing post analytics, displayed next to the buttons and in the stats table.
- Add endpoints to record a like or a dislike for a post.
- Reactions are recorded **synchronously** on submit — unlike view tracking, they do **not** go through the Delayed Job worker, because a reaction is a direct user action whose result must be visible on the next page render.
- Seed data is backfilled with like/dislike counts so the feature is visible on a fresh database.

**Non-goal: vote deduplication.** Reactions are anonymous and unlimited — a visitor may like or dislike a post any number of times, and counts only ever increase. Per-visitor or per-account de-duplication is intentionally out of scope (the app has no authentication or session-identity concept). This is a deliberate scope decision, not an oversight.

## Capabilities

### New Capabilities
- `post-reactions`: Recording anonymous like/dislike reactions on a post and displaying the aggregate counts.

### Modified Capabilities
<!-- None. openspec/specs/ contains no existing specs; this is the repository's first capability. -->

## Impact

- **Data**: new `like_count` and `dislike_count` columns on the `post_analytics` table (new migration); reaction counts live alongside the existing view/reading-time metrics.
- **Routes**: new POST routes for recording a like and a dislike on a post.
- **Controllers**: `PostsController` (or a dedicated reactions action) handles the two new endpoints; `StatsController` selects the new columns.
- **Views**: post show page gains two `button_to` forms and the current counts; stats table gains like/dislike columns.
- **Seeds**: `db/seeds.rb` populates reaction counts.
- **Not affected**: `PostAnalyticsProcessorJob` and the Delayed Job worker — reactions bypass the async path entirely.
