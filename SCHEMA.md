---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

<!--toc:start-->

- [Simple & Lightweight Internal Database](#simple-lightweight-internal-database)

<!--toc:end-->

# Simple & Lightweight Internal Database

| _Item_ field     | Type               | Description                                      |
| ---------------- | ------------------ | ------------------------------------------------ |
| Key : `id`       | `INTEGER`          | Technical unique identifier of the _item_        |
| `url`            | `TEXT NOT NULL`    | File path or HTTP(S) URL of the _item_           |
| `parameters`     | `JSON`             | Parameters for parametric _items_                |
| `stability`      | `REAL NOT NULL`    | (FSRS) stability metric                          |
| `difficulty`     | `REAL NOT NULL`    | (FSRS) difficulty metric                         |
| `elapsed_days`   | `INTEGER NOT NULL` | Days since last review                           |
| `scheduled_days` | `INTEGER NOT NULL` | Days until next scheduled review                 |
| `reps`           | `INTEGER NOT NULL` | Number of repetitions                            |
| `lapses`         | `INTEGER NOT NULL` | Number of lapses                                 |
| `state`          | `INTEGER NOT NULL` | Learning state, 0-3: New, Learn, Review, Relearn |
| `review`         | `DATETIME`         | Date (and time) of the last _item’s_ review      |
| `creation`       | `DATETIME`         | Date (and time) of the _item’s_ creation         |

| _Tag_ field | Type            | Description                                 |
| ----------- | --------------- | ------------------------------------------- |
| Key : `id`  | `INTEGER`       | Technical unique identifier of the _tag_    |
| `name`      | `TEXT NOT NULL` | Name of the _tag_                           |
| `parent`    | `INTEGER`       | ID of the parent _tag_, null if root        |
| `retention` | `INTEGER < 256` | Desired last 50 % of retention factor       |
| `weights`   | `JSON`          | (FSRS) 'w' array (e.g., [0.4, 0.6, 2.4, …]) |

```sqlite
CREATE TABLE item(
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- Technical
  url TEXT NOT NULL,        -- file://… | http://… | https://…
  parameters JSON NOT NULL, -- JSON attribute set of parametric item parameters
  stability REAL NOT NULL DEFAULT 0,    -- FSRS Stability
  difficulty REAL NOT NULL DEFAULT 0,   -- FSRS Difficulty
  elapsed INTEGER NOT NULL DEFAULT 0,   -- FSRS Elapsed Days
  scheduled INTEGER NOT NULL DEFAULT 0, -- FSRS Scheduled Days
  reps INTEGER NOT NULL DEFAULT 0,      -- FSRS Repetitions
  lapses INTEGER NOT NULL DEFAULT 0,    -- FSRS Lapses
  state INTEGER NOT NULL DEFAULT 0 CHECK (state < 4), -- FSRS Learning State
  review DATETIME,                             -- Last review date
  creation DATETIME DEFAULT CURRENT_TIMESTAMP, -- Initial creation date
  UNIQUE(url, parameters)
);

CREATE TABLE tag(
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- Technical
  name TEXT NOT NULL, -- Actual text of the tag
  parent INTEGER, -- ID of the parent tag, null if root tag
  retention INTEGER CHECK (retention < 256), -- (retention + 256) / 511
  weights JSON, -- FSRS 'w' array, to optimize sometimes
  FOREIGN KEY (parent) REFERENCES tag(id) ON DELETE CASCADE,
  UNIQUE(name, parent) -- Prevents duplicate children under the same parent
);

CREATE TABLE item_tags(
  item INTEGER NOT NULL, -- Many-to-many relationship
  tag INTEGER NOT NULL,  -- between items and tags
  PRIMARY KEY (item, tag),
  FOREIGN KEY (item) REFERENCES item(id) ON DELETE CASCADE,
  FOREIGN KEY (tag) REFERENCES tag(id) ON DELETE CASCADE
);
```

The database only stores _tags_ created or modified by the user in their own
`tag` row, not _tags_ predefined in _items_ files. These, however, could be
cached elsewhere if needed for performance.
