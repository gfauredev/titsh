---
lang: en-GB
---

<!--toc:start-->

- [Titsh](#titsh)
  - [Flexible & Powerful Items](#flexible-powerful-items)
    - [Item Presentation](#item-presentation)
    - [Item Answer Evaluation](#item-answer-evaluation)
    - [Item Scheduling](#item-scheduling)
  - [Parametric Items](#parametric-items)
  - [Items Repositories & Sharing](#items-repositories-sharing)
  - [Tagging](#tagging)
  - [Required References](#required-references)
  - [Technical ~~Limitations~~ Simplicity](#technical-limitations-simplicity)
    - [Read-only source Item files](#read-only-source-item-files)
    - [Isolated and stateless (lightweight) scripting environment](#isolated-and-stateless-lightweight-scripting-environment)
    - [Simple & Lightweight Internal Database](#simple-lightweight-internal-database)

<!--toc:end-->

# Titsh

**Titsh** is a cross-platform app _teaching_ atomic **skills** or units of
**knowledge** (_Items_) **efficiently**, while _tracking_ their
[long term](https://en.wikipedia.org/wiki/Long-term_memory) **retention**.

**Titsh** tries to implement
[evidence-based education](https://en.wikipedia.org/wiki/Evidence-based_education).

**Memory** is made a choice by
[(pro)actively](https://en.wikipedia.org/wiki/Active_learning) and
[regularly](https://en.wikipedia.org/wiki/Spaced_repetition) **reinforcing** it
through [problems](https://en.wikipedia.org/wiki/Problem-based_learning).

Learners are [engaged](https://en.wikipedia.org/wiki/Gamification) with dynamic
UIs, tailored [user input](https://en.wikipedia.org/wiki/Testing_effect) and
[evaluation](https://en.wikipedia.org/wiki/Desirable_difficulty).

[Recall](https://en.wikipedia.org/wiki/Recall_(memory)) is sped up by
[linking](https://en.wikipedia.org/wiki/Integrative_learning) _Items_ to
prerequisite, complementary or related ones.

## Flexible & Powerful Items

_Items_ are written in **lightweight markup** languages, in standard **text
files**, editable by any text editor, easily shared and version controlled. They
can also be bundled with _resources_ (e.g. images, data…).

_Item_ files include **scripts** in **lightweight scripting** languages that can
customize their _Presentation_ and _Evaluation_.

Currently, **Titsh** supports [Markdown](https://commonmark.org) (parsed by
[pulldown-cmark]) markup and embedded [Rhai] scripts.

### Item Presentation

In **Titsh**, an _Item’s_ _Presentation_ is more than static content ; it adds
**interactivity** and **dynamic elements** to optimize the learning. **Titsh**
is not only a **memory** app, and _Presentation_ is responsible for handling the
_acquisition_ phase, making the user understand a concept never studied before.

For example, an _Item_ about countries location can be _presented_ as an
interactive map where the _user_ has to click the correct “shape”. A “reverse”,
**linked** _Item_ could highlight a country and ask the _user_ to select its
name among some plausible ones. Or, an _Item_ about equations could display each
side as a plate of a balance scale, with factors as weights.

### Item Answer Evaluation

**Titsh** can make the _user_ auto-evaluate with classic
[Anki](https://docs.ankiweb.net/studying.html#answer-buttons) “Again”, “Hard”,
“Good” or “Easy” buttons.

But **Titsh** prioritizes **active** and **performance-based** evaluation
through custom _Evaluation_, working in pair with the _Presentation_.

For example, the _Item_ about countries location could _Evaluate_ the _user_ :

- Correct shape/name, Quickly (i.e. < 5s) → “Easy”
- Correct shape/name, Moderately (i.e. < 25s) → “Good”
- Correct shape/name, Slowly (i.e. > 25s) → “Hard”
- Incorrect shape/name, or None after timeout (i.e. 90s) → “Again”

### Item Scheduling

**Titsh** schedules _Item_ [just](https://en.wikipedia.org/wiki/Spacing_effect)
before they are likely to be
[forgotten](https://en.wikipedia.org/wiki/Forgetting_curve), to maximize
**retention** while minimizing time spent _learning_, using the [FSRS] algorithm
(with [fsrs-rs] implementation).

## Parametric Items

An _Item_ file normally represents a single atomic knowledge unit. **Titsh**
also supports _Parametric Item_ files, which declares _variable fields_ to
generate several knowledge units that are similar but of which some parameters
differ. In that case, each “virtual” _Item_ is _Tracked_ independently.

For example, instead of writing ~200 very similar _Items_ about countries
location, one _Parametric Item_ file can be used to generate all the necessary
_Items_ by variating its country name and “shape” _Parameters_.

Each _Parametric Item_ variant is identified by its path plus its parameters’
values in **Titsh** internal SQLite database (via [sqlx]). _Parameter_ rows can
be imported from supported data formats.

## Items Repositories & Sharing

**Titsh** can use _Items_ from the local, on-disk _Items Repository_, or from
remote HTTP _Repositories_ (provided their URL) while keeping them up-to-date.

This allows to easily share _Items Repositories_ through a web or Git server.
For now, it’s up to the user to find interesting and trustable _Items
Repositories_; a ranking system to quickly find high-quality ones is planned.

## Tagging

_Items_ are organized flexibly with _Tags_, not in rigid categories or folders.
However, _Tags_ can be hierarchical (e.g. `math/algebra/linear/`), and **Titsh**
generates _Item’s_ first _Tag(s)_ from its path (relative to the _Repository_).

The more _Tags_ different _Items_ share, the more **Titsh** see them as
_Related_ (or Complementary). Therefore, **Titsh** can present them during
review sessions to reinforce learning.

Extremely _Related_ _Items_ may be considered different ways of presenting the
same knowledge, and the _scheduling_ logic might decide to mark such related
_Items_ simultaneously as reviewed for the current session.

## Required References

_Items_ can reference other _Items_ or _Tags_ as _Required_ (or _Preliminary_).
Should a _user_ forget (“Again”) an _Item_ two times in a row, **Titsh** will
suggest _Pausing_ it while learning the direct requirements, and continue
_recursively_ if needed.

**Titsh** encourages
[goal-based](https://en.wikipedia.org/wiki/Project-based_learning) learning,
starting from the _user’s_ desired **knowledge** or **skill** and getting the
background only as strictly required.

## Technical ~~Limitations~~ Simplicity

**Titsh** is [kept simple](https://en.wikipedia.org/wiki/KISS_principle), but
may grow in future versions if really needed.

### Read-only source Item files

- _Tracking_ entirely inside internal database
- YAML or TOML front-matter
- Identified only by their paths, relative to the single _Item Repository_
- Marked as “Lost” if file or (_Parameters_) row not found / (re)moved
  - _User_ can update “lost” _Items’_ path or row ID, or definitively remove
  - Progress _Tracking_ data is never deleted without explicit _user_ action
  - Prompt to relink or remove when it should be reviewed

```markdown
---
requires: [Reading/English]
tags:
  - Item/English
  - Geography/Countries/France
  - Countries/France
ressources: [worldMap.png]
params: [country-shape.json] # Map of country names to shapes
thresholds: [5s, 25s, 90s] # Base thresholds triggering Good, Hard and Timeout
---
```

### Isolated and stateless (lightweight) scripting environment

- Restricted set of inputs
  - Whether the _Item_ is reviewed or initially learned
  - _User_ mouse or touchscreen events, text input
  - Date and time
  - Eventual attribute set of parameters (if params is set, parametric _item_)
  - Eventual resources (images, sounds…) declared in front-matter
- Very restricted set of outputs
  - Rendered object displayed in place of the code block
  - Eventual sound played to the user
  - _Evaluation_ enum : “Again”, “Hard”, “Good”, “Easy”

````markdown
# Country Name

```rhai presentation
# Get the country name and shape data from Titsh (according to Scheduling logic)

# Return a world map with the shape data (country) highlighted (whiter)
```

## Select the highlighted country (among the options)

```rhai evaluation
# Display a correct name button scrambled among (e.g. five) plausible ones

# Wait for the user to click a button or timeout after thresholds[2]

# Return the evaluation enum
# - "Easy" if correct and in less than thresholds[0]
# - "Good" if correct and in less than thresholds[1]
# - "Hard" if correct and in more than thresholds[1]
# - "Again" wrong or absent answer
```
````

### Simple & Lightweight Internal Database

| _Item_ field     | Type               | Description                                       |
| ---------------- | ------------------ | ------------------------------------------------- |
| `id` Primary Key | `INTEGER`          | Technical unique identifier of the _Item_         |
| `url`            | `TEXT NOT NULL`    | File path or HTTP(S) URL of the _Item_            |
| `parameters`     | `JSON`             | Parameters for parametric _Items_                 |
| `tags`           | `JSON NOT NULL`    | (JSON) Array of _Tags_ associated with the _Item_ |
| `stability`      | `REAL NOT NULL`    | (FSRS) stability metric                           |
| `difficulty`     | `REAL NOT NULL`    | (FSRS) difficulty metric                          |
| `elapsed_days`   | `INTEGER NOT NULL` | Days since last review                            |
| `scheduled_days` | `INTEGER NOT NULL` | Days until next scheduled review                  |
| `reps`           | `INTEGER NOT NULL` | Number of repetitions                             |
| `lapses`         | `INTEGER NOT NULL` | Number of lapses                                  |
| `state`          | `INTEGER NOT NULL` | Learning state, 0-3: New, Learn, Review, Relearn  |
| `review`         | `DATETIME`         | Date (and time) of the last _Item’s_ review       |
| `creation`       | `DATETIME`         | Date (and time) of the _Item’s_ creation          |

| _Tag_ field      | Type                    | Description                                 |
| ---------------- | ----------------------- | ------------------------------------------- |
| `id` Primary Key | `INTEGER`               | Technical unique identifier of the _Tag_    |
| `name`           | `TEXT NOT NULL`         | Name of the _Tag_                           |
| `parent`         | `INTEGER`               | ID of the parent _Tag_, null if root        |
| `retention`      | `500 < INTEGER <= 1000` | Desired retention factor on 1000            |
| `weights`        | `JSON`                  | (FSRS) 'w' array (e.g., [0.4, 0.6, 2.4, …]) |

```sqlite
CREATE TABLE item(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  url TEXT NOT NULL,  -- file://… or http://… or https://…
  parameters JSON,    -- JSON attribute set of parametric items’ parameters
  tags JSON NOT NULL, -- JSON array of (slash hierarchized) item’s tags
  stability REAL NOT NULL DEFAULT 0,         -- FSRS
  difficulty REAL NOT NULL DEFAULT 0,        -- FSRS
  elapsed_days INTEGER NOT NULL DEFAULT 0,   -- FSRS
  scheduled_days INTEGER NOT NULL DEFAULT 0, -- FSRS
  reps INTEGER NOT NULL DEFAULT 0,           -- FSRS
  lapses INTEGER NOT NULL DEFAULT 0,         -- FSRS
  state INTEGER NOT NULL DEFAULT 0, -- 0: New, 1: Learn, 2: Review, 3: Relearn
  review DATETIME,                             -- Last review date
  creation DATETIME DEFAULT CURRENT_TIMESTAMP, -- Initial creation date
  UNIQUE(url, parameters, tags)
);

CREATE TABLE tag(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  parent INTEGER, -- ID of the parent tag, null if root tag
  retention INTEGER CHECK (retention > 500 AND retention <= 1000), -- /1000
  weights JSON, -- FSRS 'w' array (e.g., [0.4, 0.6, 2.4, ...])
  FOREIGN KEY (parent) REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE(name, parent) -- Prevents duplicate children under the same parent
);

CREATE TABLE item_tags(
  item INTEGER NOT NULL,
  tag INTEGER NOT NULL,
  PRIMARY KEY (item, tag),
  FOREIGN KEY (item) REFERENCES item(id) ON DELETE CASCADE,
  FOREIGN KEY (tag) REFERENCES tag(id) ON DELETE CASCADE
);
```

The database only stores _Tags_ created or modified by the _user_ in their own
`tag` row. _Tags_ predefined in _Items_ files are just added to the _Item’s_
`tags` array for uniqueness.

[Rust]: https://rust-lang.org
[Dioxus]: https://dioxuslabs.com
[FSRS]: https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm
[fsrs-rs]: https://github.com/open-spaced-repetition/fsrs-rs
[sqlx]: https://github.com/launchbadge/sqlx
[serde]: https://github.com/serde-rs/serde
[gray-matter]: https://github.com/yuchanns/gray-matter-rs
[pulldown-cmark]: https://github.com/pulldown-cmark/pulldown-cmark
[AsciiDoc]: https://asciidoc.org
[reStructuredText]: https://docutils.sourceforge.io/rst.html
[Typst]: https://typst.app
[Typst Core]: https://github.com/typst/typst
[Boa]: https://github.com/boa-dev/boa
[RustPython]: https://github.com/RustPython/RustPython
[mLua]: https://github.com/mlua-rs/mlua
[Gleam]: https://github.com/gleam-lang/gleam
[Steel]: https://github.com/mattwparas/steel
[Rhai]: https://github.com/rhaiscript/rhai
[Wasmi]: https://github.com/wasmi-labs/wasmi
[WasmTime]: https://github.com/bytecodealliance/wasmtime
