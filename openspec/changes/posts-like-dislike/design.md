## Context

The blog stores authoritative, request-path data on `posts` and worker-computed, eventually-consistent metrics on `post_analytics` (written only by `PostAnalyticsProcessorJob`). This change adds anonymous like/dislike reactions. Per the proposal's `/opsx:explore` revision, reaction counts live on `posts` — they are synchronous, exact, request-path facts and do not belong in the worker-owned analytics table. The app has no authentication, no JavaScript build step beyond importmap, and runs SQLite in dev/test and PostgreSQL in production.

## Goals / Non-Goals

**Goals:**
- Record likes and dislikes synchronously and show the result on the next render.
- Display a single `score` (`likes − dislikes`) on the index and the full breakdown on the show page.
- Work with no client-side JavaScript.
- Behave correctly under concurrent reactions to the same post.

**Non-Goals:**
- Vote deduplication or any per-visitor/per-account identity (explicit non-goal from the proposal).
- Touching `post_analytics`, `PostAnalyticsProcessorJob`, or the Delayed Job worker.
- Undo/un-react, reaction history, or storing `score` as a column.

## Decisions

### 1. Counts as integer columns on `posts`, default `0`, non-null
Settled in exploration. Defaults make every post — including ones never reacted to — report `0/0` with no `COALESCE` or find-or-create. *Alternative:* `post_analytics` columns — rejected (breaks the worker-owned invariant; forces a join/N+1 on the index; analytics row may not exist yet).

### 2. Atomic increment, not load-modify-save
Recording a reaction uses an atomic SQL increment (`Post.update_counters` / `increment_counter`), not `record.increment!` after a load. Two concurrent likes must yield `+2`. *Alternative:* read-modify-write — rejected: a lost update under concurrency would silently drop reactions, and the spec requires counts to only ever increase by the number of actions.

### 3. `score` is a model method, never persisted
`Post#score` returns `like_count - dislike_count`. Computed on read so it can never drift from its inputs. *Alternative:* a stored/cached `score` column — rejected as needless denormalization for a subtraction.

### 4. Two member routes, handled in `PostsController`
`POST /posts/:id/like` and `POST /posts/:id/dislike`, added as member routes on `resources :posts`, handled by `PostsController#like` and `#dislike`. *Alternatives:* a dedicated `ReactionsController` (cleaner separation, but more surface than this small feature warrants) or a single `#react` action keyed by a param (saves one method but obscures the routes). Two explicit actions read best in a talk demo.

### 5. `button_to` for controls; redirect back to origin
The like/dislike controls render as `button_to`, which emits a real `<form method="post">` with Rails' CSRF token — no JavaScript. After recording, the action calls `redirect_back(fallback_location: post_path(post))` so a reaction from the show page returns to the show page (and the fallback covers a missing `Referer`). Controls appear only on the show page; the index shows `score` as read-only text, per the spec.

### 6. Seed backfill
`db/seeds.rb` sets non-zero `like_count`/`dislike_count` on seeded posts so a fresh database demonstrates varied scores (including a negative one).

## Risks / Trade-offs

- **Counts are inflatable (no dedup)** → Accepted, explicit non-goal. A reviewer seeing repeated-increment behavior should read it as intended, not a bug; the spec encodes it.
- **`redirect_back` with no `Referer`** → Mitigated by `fallback_location: post_path(post)`.
- **Migration on an existing table** → Add columns with `default: 0, null: false`; existing rows backfill to `0` automatically. Low risk on SQLite/PG at demo scale.
- **GET vs POST** → Reactions mutate state, so they MUST be POST (handled by `button_to`); a crawler following a GET link must never change counts.

## Migration Plan

1. Migration: add `like_count` and `dislike_count` to `posts` (`integer, default: 0, null: false`).
2. Deploy is forward-only; rollback = drop the two columns (no data worth preserving in the demo).
3. No production data migration needed beyond the column defaults.

## Open Questions

- None blocking. Naming (`score`) is settled; if the show page's "total" should instead mean `likes + dislikes` (engagement volume) rather than the net score, that is a one-line label change confined to the show view.
