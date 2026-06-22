# post-reactions Specification

## Purpose
Anonymous, no-JavaScript like/dislike reactions on posts: recording reactions synchronously, the derived net `score`, and how reactions are displayed on the index and show pages.

## Requirements
### Requirement: Recording a like
The system SHALL provide a way to record a like for a post, increasing that post's `like_count` by one. The like SHALL be recorded synchronously on the request and SHALL NOT be enqueued to the background worker.

#### Scenario: Liking a post
- **WHEN** a visitor submits the like action for a post
- **THEN** the post's `like_count` increases by one
- **AND** the visitor is returned to the page they came from with the updated count visible

#### Scenario: Like is not deferred to the worker
- **WHEN** a like is recorded
- **THEN** the updated `like_count` is visible on the next page render without any background job running

### Requirement: Recording a dislike
The system SHALL provide a way to record a dislike for a post, increasing that post's `dislike_count` by one. The dislike SHALL be recorded synchronously on the request and SHALL NOT be enqueued to the background worker.

#### Scenario: Disliking a post
- **WHEN** a visitor submits the dislike action for a post
- **THEN** the post's `dislike_count` increases by one
- **AND** the visitor is returned to the page they came from with the updated count visible

### Requirement: Reactions are anonymous and unbounded
The system SHALL accept like and dislike actions from any visitor without authentication, and SHALL NOT limit how many times a visitor may react. Counts SHALL only ever increase. Vote deduplication is explicitly out of scope.

#### Scenario: Repeated likes from the same visitor
- **WHEN** the same visitor submits the like action for a post three times
- **THEN** the post's `like_count` increases by three

#### Scenario: No authentication required
- **WHEN** a visitor who is not signed in submits a like or dislike
- **THEN** the reaction is recorded successfully

### Requirement: Computed score
A post SHALL expose a `score` equal to `like_count` minus `dislike_count`. The score SHALL be computed on read and SHALL NOT be persisted. The score MAY be negative.

#### Scenario: Score reflects the difference
- **WHEN** a post has a `like_count` of 7 and a `dislike_count` of 2
- **THEN** its `score` is 5

#### Scenario: Score can be negative
- **WHEN** a post has a `like_count` of 1 and a `dislike_count` of 4
- **THEN** its `score` is -3

### Requirement: Default reaction counts
A post that has never received a reaction SHALL report a `like_count` of zero, a `dislike_count` of zero, and a `score` of zero.

#### Scenario: Newly created post
- **WHEN** a post is created and has received no reactions
- **THEN** its `like_count` is 0, its `dislike_count` is 0, and its `score` is 0

### Requirement: Reaction display on the index page
The post index SHALL display each post's `score` as a single value. The like and dislike breakdown SHALL NOT be required on the index.

#### Scenario: Index shows the score
- **WHEN** the index page lists a post whose `like_count` is 10 and `dislike_count` is 3
- **THEN** the post's entry shows a score of 7

### Requirement: Reaction display and controls on the show page
The post show page SHALL display the post's `score` together with its `like_count` and `dislike_count`, and SHALL present a like control and a dislike control. The controls SHALL function without client-side JavaScript.

The `score` and the two controls SHALL be grouped into a single, visually distinct reactions section, laid out on one row, set apart from the article content and from the author actions (edit/delete).

#### Scenario: Show page presents the full picture and controls
- **WHEN** a visitor opens a post's show page
- **THEN** the page displays the post's `score`, `like_count`, and `dislike_count`
- **AND** the page presents a like control and a dislike control that submit without JavaScript

#### Scenario: Reactions are a distinct single-row section
- **WHEN** a visitor opens a post's show page
- **THEN** the `score` and the like/dislike controls appear together in one labelled reactions section, on a single row, visually separated from the article content and the author actions

