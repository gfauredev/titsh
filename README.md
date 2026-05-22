---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

<!--toc:start-->

- [Flexible & Powerful Items](#flexible-powerful-items)
  - [Item Presentation](#item-presentation)
  - [Item Answer Evaluation](#item-answer-evaluation)
  - [Item Scheduling](#item-scheduling)
  - [Parametric Items](#parametric-items)
  - [Items Repositories & Sharing](#items-repositories-sharing)
  - [Tagging](#tagging)
  - [Required References](#required-references)
- [Technical ~~Limitations~~ Simplicity](#technical-limitations-simplicity)
  - [Read-only Source Item Files](#read-only-source-item-files)
  - [Isolated and Stateless (Lightweight) Scripting Environment](#isolated-and-stateless-lightweight-scripting-environment)
    - [Titsh Scripting API](#titsh-scripting-api)
      - [threshold()](#threshold)
  - [Simple & Lightweight Internal Database](#simple-lightweight-internal-database)

<!--toc:end-->

**Titsh** is a cross-platform app teaching atomic **skills** or units of
**knowledge** (_items_) **efficiently**, while _tracking_ their
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
[linking](https://en.wikipedia.org/wiki/Integrative_learning) _items_ to
prerequisite, complementary or related ones.

# Flexible & Powerful Items

_Items_ are written in **lightweight markup** languages, in standard **text
files**, editable by any text editor, easily shared and version controlled. They
can also be bundled with _resources_ (e.g. images, data…).

_Item_ files include **scripts** in **lightweight scripting** languages that can
customize their _presentation_ and _evaluation_.

First version of **Titsh** will likely support
[Markdown](https://commonmark.org) (parsed by [pulldown-cmark]) markup with
embedded [Rhai] scripts.

## Item Presentation

In **Titsh**, an _item’s_ _presentation_ is more than static content ; it adds
**interactivity** and **dynamic elements** to optimize learning. **Titsh** is
not only a **memory** app ; _presentation_ is responsible for handling the
_acquisition_ phase, making the user understand a concept never studied before.

For example, an _item_ about countries location can be _presented_ as an
interactive map where the user has to click the correct “shape”. A “reverse”,
**linked** _item_ could highlight a country and ask the user to select its name
among some plausible ones. Or, an _item_ about equations could display each side
as a plate of a balance scale, with factors as weights ; creating an intuition
of the preservation of equality.

## Item Answer Evaluation

**Titsh** can make the user auto-evaluate with classic
[Anki](https://docs.ankiweb.net/studying.html#answer-buttons) “Again”, “Hard”,
“Good” or “Easy” buttons.

But **Titsh** prioritizes **active** and **performance-based** evaluation
through custom _evaluation logic_, working in pair with the _presentation_.

For example, the _item_ about countries location could _evaluate_ the user :

- Correct shape/name, quickly (i.e. < 5s) → “Easy”
- Correct shape/name, moderately (i.e. < 25s) → “Good”
- Correct shape/name, slowly (i.e. > 25s) → “Hard”
- Incorrect shape/name, or none after timeout (i.e. 90s) → “Again”

## Item Scheduling

**Titsh** schedules _item_ [just](https://en.wikipedia.org/wiki/Spacing_effect)
before they are likely to be
[forgotten](https://en.wikipedia.org/wiki/Forgetting_curve), to maximize
**retention** while minimizing time spent _learning_, using the [FSRS] algorithm
(with [fsrs-rs] implementation) or a custom variant.

## Parametric Items

An _item_ file normally represents a single atomic knowledge unit. **Titsh**
also supports _parametric item_ files, which declares _variable fields_ to
generate several knowledge units that are similar but of which some parameters
differ. In that case, each “virtual” _item_ is _tracked_ independently.

For example, instead of writing ~200 very similar _items_ about countries
location, one _parametric item_ file can be used to generate all the necessary
_items_ by variating its country name and “shape” _parameters_.

Each _parametric item_ variant is identified by its path plus its parameters’
values in **Titsh** internal database (likely [SQLite] via [sqlx]). _Parameters_
can be imported from files of supported data formats.

## Items Repositories & Sharing

**Titsh** stores _item_ files in a local, on-disk _items repository_. This
repository can contain clones of other remote HTTP _repositories_ (provided
their URL) ; **Titsh** will offer the user to sync them at startup.

This allows to easily share _items repositories_ through a web or Git server.
For now, it’s up to the user to find interesting and trustable _items
repositories_; a ranking system to quickly find high-quality ones is planned.

## Tagging

_Items_ are organized flexibly with _tags_, not in rigid categories or folders.
However, _tags_ can be hierarchical (e.g. `math/algebra/linear/`), and **Titsh**
generates _item’s_ first _tag(s)_ from its path (relative to the _repository_).

The more _tags_ different _items_ share, the more **Titsh** see them as
_related_ (or complementary). Therefore, **Titsh** can present them during
review sessions to reinforce learning.

Extremely _related_ _items_ may be considered different ways of presenting the
same knowledge, and the _scheduling_ logic might decide to mark such related
_items_ simultaneously as reviewed for the current session.

## Required References

_Items_ can reference other _items_ or _tags_ as _required_ (or preliminary).
Should a user forget (“Again”) an _item_ two times in a row, **Titsh** will
suggest _pausing_ it while learning the direct requirements, and continue
_recursively_ if needed.

**Titsh** encourages
[goal-based](https://en.wikipedia.org/wiki/Project-based_learning) learning,
starting from the user’s desired **knowledge** or **skill** and getting the
background only as strictly required.

# Technical ~~Limitations~~ Simplicity

**Titsh** is [kept simple](https://en.wikipedia.org/wiki/KISS_principle), but
may grow in future versions if really needed.

## Read-only Source Item Files

- _Tracking_ entirely inside internal database
- YAML or TOML front-matter
- Identified only by their paths, relative to the single _item repository_
- Marked as “Lost” if file or _parameters_ not found / (re)moved
  - User can update “lost” _items’_ path or _parameters_, or definitively remove
  - Progress _tracking_ data is never deleted without explicit user action
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
---
```

## Isolated and Stateless (Lightweight) Scripting Environment

- Restricted set of inputs
  - Whether the _item_ is reviewed or initially learned
  - User mouse or touchscreen events, text input
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
# Titsh provides a 'params' object for parametric items
let country_name = params.get("name"); 
let country_shape = params.get("shape_id");

# 1. Create a container for the map
let map_container = create_element("div");

# 2. Load the resource declared in front-matter
let world_map = load_resource("worldMap.png");

# 3. Render the map with a highlight filter on the specific shape
# 'render_svg_overlay' is a hypothetical Titsh helper function
let rendered_content = render_svg_overlay(world_map, country_shape, "#{fill: 'white'; opacity: 0.8}");

# Return the object to be displayed in the UI
rendered_content;
```

## Select the highlighted country (among the options)

```rhai evaluation
# Declare and start base (default) thresholds (in s) triggering Good, Hard and Timeout
threshold(5, 25, 90) # Titsh could increase them according to difficulty, user needs…

# Generate multiple choice buttons (shuffled)
let choices = params.get("distractors"); # e.g. ["Germany", "Spain", …]
# Or do it randomly / by similarity algo / by learning model…
choices.push(params.get("name"));
choices.shuffle();

# Wait for User Interaction
# 'wait_for_click' blocks until a button is pressed or timeout occurs
let user_choice = wait_for_click(choices, thresholds[2]); 

# Logic to determine the Evaluation Enum
let duration = now() - start_time;

if user_choice == params.get("name") {
    if duration < thresholds[0] {
        return "Easy"; # Correct and fast
    } else if duration < thresholds[1] {
        return "Good"; # Correct and moderate
    } else {
        return "Hard"; # Correct but slow
    }
} else {
    return "Again";    # Incorrect or Timeout
}
```
````

### **Titsh** Scripting API

Objects provided from front-matter… <!-- TODO -->

#### threshold()

<!-- TODO -->

## Simple & Lightweight Internal Database

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

[Rust]: https://rust-lang.org
[Dioxus]: https://dioxuslabs.com
[FSRS]: https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm
[fsrs-rs]: https://github.com/open-spaced-repetition/fsrs-rs
[sqlx]: https://github.com/launchbadge/sqlx
[serde]: https://github.com/serde-rs/serde
[gray-matter]: https://github.com/yuchanns/gray-matter-rs
[pulldown-cmark]: https://github.com/pulldown-cmark/pulldown-cmark
[AsciiDoc]: https://asciidoc.org
[Typst]: https://typst.app
[Typst Core]: https://github.com/typst/typst
[reStructuredText]: https://docutils.sourceforge.io/rst.html
[Rhai]: https://github.com/rhaiscript/rhai
[Steel]: https://github.com/mattwparas/steel
[SQLite]: https://sqlite.org
[mLua]: https://github.com/mlua-rs/mlua
[Gleam]: https://github.com/gleam-lang/gleam
[Boa]: https://github.com/boa-dev/boa
[RustPython]: https://github.com/RustPython/RustPython
[Wasmi]: https://github.com/wasmi-labs/wasmi
[WasmTime]: https://github.com/bytecodealliance/wasmtime
