## Why

Readers can view posts but have no way to signal whether they liked them, and authors have no lightweight measure of sentiment beyond raw view counts. Adding like/dislike buttons gives a simple, immediate engagement signal without requiring accounts or any client-side JavaScript.

## What Changes

- Add **like** and **dislike** buttons to the post show page, rendered as plain server-side form submissions (no JavaScript).
- Add `like_count` and `dislike_count` columns to the **`posts`** table, defaulting to `0`.
- Add a computed **`score`** (`like_count - dislike_count`) — a model method, not a stored column.
- Display reactions in two places:
  - **Index page**: the single `score` value per post.
  - **Show page**: the full picture — `score`, plus the `like_count` and `dislike_count` breakdown — grouped with the buttons in a single, visually distinct reactions section laid out on one row.
- Add endpoints to record a like or a dislike for a post.
- Reactions are recorded **synchronously** on submit — unlike view tracking, they do **not** go through the Delayed Job worker, because a reaction is a direct user action whose result must be visible on the next page render.
- Seed data is backfilled with like/dislike counts so the feature is visible on a fresh database.

**Non-goal: vote deduplication.** Reactions are anonymous and unlimited — a visitor may like or dislike a post any number of times, and counts only ever increase. Per-visitor or per-account de-duplication is intentionally out of scope (the app has no authentication or session-identity concept). This is a deliberate scope decision, not an oversight.

## Revision — counts moved from `post_analytics` to `posts` (via `/opsx:explore`)

The first draft of this proposal stored `like_count`/`dislike_count` on `post_analytics`. An `/opsx:explore` session revisited that decision **before any code was written** and reversed it, for two reasons:

1. **Architectural fit.** `post_analytics` is the *worker-owned, eventually-consistent* table — every field in it is written asynchronously by `PostAnalyticsProcessorJob`. A reaction, by contrast, is a *synchronous, exact, request-path* fact. Putting a synchronous write into the worker-owned table breaks that invariant; reactions belong with `posts`, which already holds request-path data.
2. **Read cost.** Reactions are shown on both the index (every post) and the show page. On `posts` the counts are already loaded with each post (single table, no join, defaults to `0`). On `post_analytics` the index would require a join or incur N+1, plus a find-or-create wrinkle since an analytics row does not exist until a post's first view.

Capturing this reversal here is intentional: it shows the spec being corrected during exploration rather than after implementation.

## Capabilities

### New Capabilities
- `post-reactions`: Recording anonymous like/dislike reactions on a post and displaying the aggregate counts (and the derived `score`).

### Modified Capabilities
<!-- None. openspec/specs/ contains no existing specs; this is the repository's first capability. -->

## Impact

- **Data**: new `like_count` and `dislike_count` integer columns on the **`posts`** table, default `0`, non-null (new migration). No new columns on `post_analytics`.
- **Model**: `Post` gains a `score` method (`like_count - dislike_count`); `score` is computed on read, never stored.
- **Routes**: new POST routes for recording a like and a dislike on a post.
- **Controllers**: `PostsController` (or a dedicated reactions action) handles the two new endpoints. `StatsController` needs no join change — it already selects `posts.*`, so the new columns and `score` come along for free.
- **Views**: post index renders `score` per post; post show page gains two `button_to` forms plus the `score`/likes/dislikes breakdown.
- **Seeds**: `db/seeds.rb` populates `like_count`/`dislike_count`.
- **Not affected**: `post_analytics`, `PostAnalyticsProcessorJob`, and the Delayed Job worker — reactions bypass the async path and the analytics table entirely.
