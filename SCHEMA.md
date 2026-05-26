---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

<!--toc:start-->

- [Item Table](#item-table)
  - [Item Cache Table](#item-cache-table)
- [Review Table](#review-table)
- [Tag Table](#tag-table)
  - [Tagging Table](#tagging-table)

<!--toc:end-->

# Titsh’s Simple & Lightweight Internal Database

> Each field is defined by a paragraph or two with its name, type, description
> and argument(s) about why it is required (except purely technical ones)

## Item Table

`path`: `TEXT`. File path to the item file relative to the item repository root,
required to locate the source file and identify the item.

`variant_key`: `TEXT`. Optional key for parametric items (the key in the
`params` map) which uniquely identifies a variant together with `path`.

`params`: `TEXT` (`JSON`). Parameter values to detect modifications by comparing
with current file content and to show the user what changed.

`paused`: `BOOLEAN`. 1 (true) if the user manually paused the item.

`reviews`: `INTEGER`. Number of times the item was reviewed, starting at 0 for
newly learned items. Required by the embedded scripting APIs and FSRS algorithm.

`stability`: `REAL`. FSRS stability metric (days to 90% retention), to schedule
the next optimal review date.

`difficulty`: `REAL`. FSRS inherent complexity metric (typically 1 to 10), to
adapt the spacing interval growth.

`due`: `DATETIME`. Scheduled date and time for the next review, to quickly query
which items are due for learning sessions.

```sqlite item table
CREATE TABLE item(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT NOT NULL,
  variant_key TEXT,
  params TEXT,
  paused BOOLEAN NOT NULL DEFAULT 0,
  reviews INTEGER NOT NULL DEFAULT 0,
  stability REAL,
  difficulty REAL,
  due DATETIME,
  UNIQUE(path, variant_key)
);
```

### Item Cache Table

Computable data stored separately for performance. Can be cleared and rebuilt by
scanning the item repository. Shouldn’t be backed-up or copied across systems.

`status`: `TEXT`. Result of the last file-system integrity check for that item.

- `lost`: File not found at `path`
- `modified`: File exists but differs from what stored internally
  - Params differ from `item.params`
  - Eventually, fuzzy hash differs from text file

`synced`: `DATETIME`. When the file was last checked, allows background sync to
target "stale" entries.

```sqlite item cache table
CREATE TABLE item_cache(
  item INTEGER PRIMARY KEY,
  status TEXT, -- 'lost' or 'modified', NULL if nothing to report
  synced DATETIME NOT NULL,
  FOREIGN KEY(item) REFERENCES item(id) ON DELETE CASCADE
);
```

## Review Table

`item`: `INTEGER`. Foreign key linking to the evaluated item, forms the primary
key together with `reviewed`.

`reviewed`: `DATETIME`. Exact date and time the evaluation occurred, for FSRS
calculations and chronological tracking.

`evaluation`: `TEXT`. Grade given during the review (`Again`, `Hard`, `Good`,
`Easy`), for FSRS to adjust stability and difficulty, and exposed to embedded
scripts for custom logic.

```sqlite review log table
CREATE TABLE review(
  item INTEGER NOT NULL,
  reviewed DATETIME NOT NULL,
  evaluation TEXT NOT NULL,
  PRIMARY KEY(item, reviewed),
  FOREIGN KEY(item) REFERENCES item(id) ON DELETE CASCADE
) WITHOUT ROWID;
```

## Tag Table

The database only stores _tags_ created or modified by the user in their own
`tag` row, not _tags_ predefined in _items_ files, which could however be cached
elsewhere if needed for performance.

`name`: `TEXT`. Name of the tag, for display and search operations.

`parent`: `INTEGER`. Foreign key referencing the parent tag, to support
hierarchical tags (e.g., `math/algebra/linear`). Must be unique together with
`name` to ensure a consistent path structure.

```sqlite tag table
CREATE TABLE tag(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  parent INTEGER,
  FOREIGN KEY(parent) REFERENCES tag(id) ON DELETE CASCADE,
  UNIQUE(name, parent)
);
```

### Tagging Table

Many-to-many relationship between items and tags. Required to find related items
(by shared tags) or to query items by their categories.

`item`: `INTEGER`. Foreign key to the tagged item.

`tag`: `INTEGER`. Foreign key to the associated tag.

```sqlite tagging association table
CREATE TABLE tagging(
  item INTEGER NOT NULL,
  tag INTEGER NOT NULL,
  PRIMARY KEY(item, tag),
  FOREIGN KEY(item) REFERENCES item(id) ON DELETE CASCADE,
  FOREIGN KEY(tag) REFERENCES tag(id) ON DELETE CASCADE
);
```
