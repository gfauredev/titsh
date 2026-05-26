---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

<!--toc:start-->

- [Item Presentation](#item-presentation)
- [Item Answer Evaluation](#item-answer-evaluation)
- [Item Scheduling](#item-scheduling)
- [Parametric Items](#parametric-items)
- [Items Repositories & Sharing](#items-repositories-sharing)
- [Tagging](#tagging)
- [Required References](#required-references)
- [Technical ~~Limitations~~ Simplicity](#technical-limitations-simplicity)
  - [Read-only Simple Text Source Item Files](#read-only-simple-text-source-item-files)
  - [Isolated and Stateless (Lightweight) Scripting Environment](#isolated-and-stateless-lightweight-scripting-environment)
- [Licensing and Credits](#licensing-and-credits)

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

First version of **Titsh** will likely support [Markdown] (parsed by
[pulldown-cmark]) for markup and [Rhai] for embedded scripts.

## Item Presentation

In **Titsh**, an _item’s_ _presentation_ is more than static content ; it adds
**interactivity** and **dynamic elements** to optimize learning. **Titsh** is
not only a **memory** app ; _presentation_ is considered responsible for
handling the _acquisition_ phase if needed (e.g. if review count is 0), making
the user understand a concept never studied before.

For example, an _item_ about countries location can be _presented_ as an
interactive map where the user has to click the correct “shape”. A “reverse”,
**linked** _item_ could highlight a country and ask the user to select its name
among some plausible ones. Or, an _item_ about equations could display each side
as a plate of a balance scale, with factors as weights ; creating an intuition
of the preservation of equality.

## Item Answer Evaluation

**Titsh** can make the user auto-evaluate with classic
[Anki-like](https://docs.ankiweb.net/studying.html#answer-buttons) “Again”,
“Hard”, “Good” or “Easy” buttons.

But **Titsh** prioritizes **active** and **performance-based** evaluation
through custom _evaluation logic_, working in pair with the _presentation_.

For example, the _item_ about countries location could _evaluate_ the user :

- Correct shape/name, quickly (i.e. < 5s) → “Easy”
- Correct shape/name, moderately (i.e. < 25s) → “Good”
- Correct shape/name, slowly (i.e. > 25s) → “Hard”
- Incorrect shape/name, or none after timeout (i.e. 90s) → “Again”

## Item Scheduling

**Titsh** schedules _items_ [just](https://en.wikipedia.org/wiki/Spacing_effect)
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
_items_ by variating its country name and “shape/position” _parameters_.

_Parameters_ themselves are a dictionary (or map) written in a textual data
format (e.g. JSON, YAML, TOML…), where the key is the _variant item’s_ name (or
identifier), and the value is the variating data used by the embedded scripts.
_Parameters_ can be placed into the front-matter or imported from a separate
file.

<!-- They can also be a bare list (or array), where each element is the _variant item’s_ defining data. -->

> When user starts learning (views for the first time without skipping) a
> parametric _item_ _variant_, **Titsh** copies its parameters into its internal
> database. This way, a change or removal can be detected, and the user safely
> asked how to handle it.

Each _parametric item_ variant is identified by its path plus its parameters’
values in **Titsh** internal database (likely [SQLite] via [sqlx]). _Parameters_
can be imported from files of supported data formats.

## Items Repositories & Sharing

**Titsh** stores _item_ files in an on-disk _items repository_. Remote
_repositories_ can be cloned (via bare HTTP download or `git clone`) in
subdirectories of it, and _items_ they contain will be picked as any other by
**Titsh**. A button offers the user to fetch updates.

This allows to easily share _items repositories_ through a web or Git server.
For now, it’s up to the user to find interesting and trustable _items
repositories_; a ranking system to quickly find high-quality ones is planned.

## Tagging

_Items_ are organized flexibly with _tags_, not in rigid categories or folders.
However, _tags_ can be hierarchical (e.g. `math/algebra/linear`), and **Titsh**
generates _item’s_ first (potentially nested) _tag_ from its containing
directory hierarchy, relative to the _repository_ root.

> In search and matching, _tags_ are case-insensitive

The more _tags_ different _items_ share, the more **Titsh** see them as
_related_ (or complementary). Therefore, **Titsh** can present them during
review sessions to reinforce learning.

Extremely _related_ _items_ (e.g. more than 90 % common tags) may be considered
different ways of presenting the same knowledge, and the _scheduling_ logic
might decide to simultaneously mark such related _items_ as reviewed for the
current session.

## Required References & Knowledge Discovery

_Items_ can reference other _items_ or _tags_ as _required_ (or preliminary).
Should a user forget (“Again”) an _item_ several (e.g. 2) times in a row,
**Titsh** will suggest _pausing_ it while learning the direct requirements, and
continue _recursively_ if needed.

Via this simple behaviour, **Titsh** encourages
[goal-based](https://en.wikipedia.org/wiki/Project-based_learning) learning,
starting from the user’s desired **knowledge** or **skill** and getting the
background only as strictly required.

Reversely, when all requirements of a _paused_ _item_ are remembered correctly
several times in a row, the _paused_ _item_ is automatically reactivated.

> This could also be based on FSRS parameters thresholds

## Technical ~~Limitations~~ Simplicity

**Titsh** is [kept simple](https://en.wikipedia.org/wiki/KISS_principle), but
may grow in future versions if really needed.

Data is stored and communicated as in [`SCHEMA.md`](SCHEMA.md), and embedded
scripts can use the [`SCRIPTING.md`](SCRIPTING.md) API.

### Read-only Simple Text Source Item Files

- _Tracking_ entirely inside internal database
- YAML or TOML front-matter
- Identified only by their paths, relative to the single _item repository_
- Marked as _lost_ if file or _parameters_ key not found / (re)moved
  - User can update _lost_ _items’_ path or _parameters_, or definitively remove
  - Progress _tracking_ data is never deleted without explicit user action
  - Prompt to relink or remove when it should be reviewed
- Marked as _modified_ if _parameters_ value different from internally stored
- Could detect modifications and be able to suggest the most similar _item_ if
  _lost_ by storing a [fuzzy hash] of it or leveraging Git similarity detection

```markdown
---
lang: en-GB
requires: [Reading/English]
tags:
  # From path: Geography/Countries/Shape
  # From lang: English
  # From presence of ressources/params: Parametric
  # From params dict: country name, e.g. France
  - Method/Visual
  - Easy
  - …
ressources: [world_map.svg] # Files accessible from scripts
params: country_shape.json # Map of country names to shapes
timeout: 60 # Default timeout in seconds, can be changed if user needs
---

# Select a country on the map by its name

…
```

### Isolated and Stateless (Lightweight) Scripting Environment

- Restricted set of inputs
  - _Item’s_ review count (0 for initially learned)
  - _Item’s_ current stability: days required for the probability of recalling
    that specific card to drop from 100 % to 90 %
  - _Item’s_ current difficulty: how inherently complex the card's concept is,
    typically between 1 and 10
  - _Item’s_ current retrievability: calculated probability that it will
    successfully be recalled today
  - History of past _item_ evaluations, timestamped
  - User mouse or touchscreen events, text input
  - Current date and time
  - Eventual "parameters" as structured data, if params is set
  - Eventual resources (images, sounds…) made available in front-matter
- Very restricted set of outputs
  - Rendered object(s) displayed in place of the code block
  - Eventual sound played to the user (in reaction to a click in the block area)
  - _Evaluation_ enum: “Again”, “Hard”, “Good”, “Easy”, “Skip”

````markdown
…

# Select a country on the map by its name

```rhai presentation
# Display the name of the country we’re searching
# Display a world map with clickable countries, random centering
ui::col([
    ui::text("Where is " + params.country + "?"),
    ui::image("world_map.svg").on_click(|x, y| {
        state.click = [x, y];
        evaluate();
    })
])
```

```rhai evaluation
# Return "Again" if wrong country shape clicked
# Return "Easy" if clicked in less than 5s
# Return "Good" if clicked in less than 25s
# Return "Hard" otherwise
if distance(state.click, params.coords) < 10.0 {
    if time < 5.0 { return Grade::Easy; }
    if time < 25.0 { return Grade::Good; }
    return Grade::Hard;
}
return Grade::Again;
```

Did you knew?:\
There is no universal agreement on the number of "countries" in the world.
Several countries are not being recognized as sovereign states by the UN system,
but are recognized by at least one UN member.
````

## Licensing and Credits

[Titsh] is licensed under the AGPL-3.0, see [LICENSE](LICENSE) for details.

[Titsh]: https://github.com/gfauredev/titsh
[AsciiDoc]: https://asciidoc.org
[Boa]: https://github.com/boa-dev/boa
[Cargo]: https://doc.rust-lang.org/cargo
[cargo test]: https://doc.rust-lang.org/cargo/commands/cargo-test.html
[cargo-llvm-cov]: https://github.com/taiki-e/cargo-llvm-cov
[Clippy]: https://github.com/rust-lang/rust-clippy
[Conventional Commits]: https://www.conventionalcommits.org
[Conventional Branch]: https://conventional-branch.github.io
[CommonMark]: https://commonmark.org
[Dioxus]: https://dioxuslabs.com
[dx]: https://dioxuslabs.com
[direnv]: https://direnv.net
[`direnv`]: https://direnv.net
[fuzzyhash-rs]: https://github.com/rustysec/fuzzyhash-rs
[fuzzy hash]: https://github.com/rustysec/fuzzyhash-rs
[`flake.nix`]: flake.nix
[FSRS]: https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm
[fsrs-rs]: https://github.com/open-spaced-repetition/fsrs-rs
[Gleam]: https://github.com/gleam-lang/gleam
[gray-matter]: https://github.com/yuchanns/gray-matter-rs
[Guilhem Fauré]: https://www.guilhemfau.re
[Git]: https://git-scm.com
[GitHub Pull Requests]: https://github.com/gfauredev/Titsh/pulls
[GitHub Issues]: https://github.com/gfauredev/Titsh/issues
[GitHub Flow]: https://githubflow.github.io
[Helix]: https://helix-editor.com
[IndexedDB]: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
[Lua]: https://www.lua.org
[Luau]: https://luau.org
[lcov]: https://github.com/linux-test-project/lcov
[lldb]: https://lldb.llvm.org
[llvm-cov]: https://llvm.org/docs/CommandGuide/llvm-cov.html
[Maestro]: https://maestro.dev
[mLua]: https://github.com/mlua-rs/mlua
[Markdown]: https://commonmark.org
[nextest]: https://nexte.st
[Nix]: https://nixos.org
[pwa]: https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps
[pagespeed insights]: https://pagespeed.web.dev
[pulldown-cmark]: https://github.com/pulldown-cmark/pulldown-cmark
[Rhai]: https://github.com/rhaiscript/rhai
[RustPython]: https://github.com/RustPython/RustPython
[Rust]: https://rust-lang.org
[reStructuredText]: https://docutils.sourceforge.io/rst.html
[renovate]: https://www.mend.io/renovate
[rust-analyzer]: https://rust-analyzer.github.io
[rust]: https://www.rust-lang.org
[rustc]: https://doc.rust-lang.org/rustc
[rustdoc]: https://doc.rust-lang.org/rustdoc
[rustfmt]: https://github.com/rust-lang/rustfmt
[Rexie]: https://github.com/wasmerio/rexie
[Rusqlite]: https://github.com/rusqlite/rusqlite
[Reqwest]: https://github.com/seanmonstar/reqwest
[Steel]: https://github.com/mattwparas/steel
[SQLite]: https://sqlite.org
[sqlx]: https://github.com/launchbadge/sqlx
[serde]: https://github.com/serde-rs/serde
[SemVer]: https://semver.org
[Serde]: https://serde.rs
[Typst]: https://typst.app
[Typst Core]: https://github.com/typst/typst
[Time]: https://github.com/time-rs/time
[Tokio]: https://tokio.rs
[VS Code]: https://code.visualstudio.com
[Web-sys]: https://rustwasm.github.io/wasm-bindgen/web-sys/index.html
[Wasmi]: https://github.com/wasmi-labs/wasmi
[WasmTime]: https://github.com/bytecodealliance/wasmtime
[yellow labs]: https://yellowlab.tools
