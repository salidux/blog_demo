## 1. Data layer

- [ ] 1.1 Generate a migration adding `like_count` and `dislike_count` to `posts` (`integer, default: 0, null: false`)
- [ ] 1.2 Run the migration and confirm `db/schema.rb` shows both columns with the `0` default

## 2. Model

- [ ] 2.1 Add `Post#score` returning `like_count - dislike_count`
- [ ] 2.2 Add a model-level helper to record a reaction via atomic increment (e.g. wrap `Post.update_counters` / `increment_counter`) so concurrent reactions are not lost

## 3. Routes and controller

- [ ] 3.1 Add member routes `post :like` and `post :dislike` to `resources :posts`
- [ ] 3.2 Add `PostsController#like` — atomically increments `like_count`, then `redirect_back(fallback_location: post_path(post))`
- [ ] 3.3 Add `PostsController#dislike` — atomically increments `dislike_count`, then `redirect_back(fallback_location: post_path(post))`
- [ ] 3.4 Add `:like` and `:dislike` to the `before_action :set_post` list

## 4. Views

- [ ] 4.1 On the show page, add `button_to` like and dislike controls (POST, no JavaScript)
- [ ] 4.2 On the show page, display the `score` with the `like_count`/`dislike_count` breakdown next to the controls
- [ ] 4.3 On the index page, display each post's `score` as read-only text (no controls)

## 5. Seed data

- [ ] 5.1 Set non-zero `like_count`/`dislike_count` on seeded posts in `db/seeds.rb`, including at least one post with a negative score

## 6. Tests

- [ ] 6.1 Model test: `score` returns likes minus dislikes, including a negative result, and defaults to 0 on a new post
- [ ] 6.2 Controller test: POST like increments `like_count` by one and redirects back
- [ ] 6.3 Controller test: POST dislike increments `dislike_count` by one and redirects back
- [ ] 6.4 Controller test: repeated likes from the same request increase the count each time (anonymous, unbounded — no dedup)
- [ ] 6.5 View/integration check: index shows the score; show page shows score, likes, dislikes, and the two controls

## 7. Verify

- [ ] 7.1 Run `bin/rails db:test:prepare test` and confirm green
- [ ] 7.2 Run `bin/rubocop` and `bin/brakeman --no-pager` and confirm clean
