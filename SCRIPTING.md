---
lang: en-GB
---

<!--toc:start-->

- [Shared Context](#shared-context)
  - [Item Table Map](#item-table-map)
  - [Review Table Map](#review-table-map)
  - [Tag Table Map](#tag-table-map)
- [Presentation API](#presentation-api)
  - [Typst Presentation (`typst presentation`)](#typst-presentation-typst-presentation)
    - [Interactivity Primitives](#interactivity-primitives)
    - [Interactive Button Example](#interactive-button-example)
  - [Rhai Logic (`rhai presentation`)](#rhai-logic-rhai-presentation)
- [Evaluation API (`rhai evaluation`)](#evaluation-api-rhai-evaluation)
- [Examples](#examples)
  - [Balance Scale (Typst + Rhai)](#balance-scale-typst-rhai)

<!--toc:end-->

# Titsh Scripting

**Titsh** allows embedded [Rhai] code blocks (tagged with `evaluation`) to
provide custom evaluation logic and state management. Additionally, a [Typst]
module with primitives for interactive UI components is provided inside [Typst]
`.typ` files and in `typst presentation` blocks inside [Markdown] `.md` files.

## Shared Context

Both **Typst** and **Rhai** (`evaluation`) code can read and write session data
to the global `state` object, shared across each code block of the current
_item_ review.

Additionally, **Typst** and **Rhai** (`evaluation`) code have access to
read-only context.

<!-- TODO Replace below types with proper Rhai types -->

| Constant | Type            | Description                               |
| :------- | :-------------- | ----------------------------------------- |
| `params` | `TEXT` (`JSON`) | Parameter values for the current variant  |
| `chrono` | `DURATION`      | Time elapsed since the item was displayed |
| `date`   | `DATETIME`      | Current (localized) date and time         |

### Item Table Map

Accessed under `item` object.

| Constant      | Type            | Description                                |
| :------------ | :-------------- | ------------------------------------------ |
| `path`        | `TEXT`          | File path relative to item repository root |
| `variant_key` | `TEXT`          | Key in the `params` map                    |
| `params`      | `TEXT` (`JSON`) | Parameter values                           |
| `paused`      | `BOOLEAN`       | 1 if the user manually paused the item     |
| `reviews`     | `INTEGER`       | Number of reviews (0 for newly learned)    |
| `stability`   | `REAL`          | FSRS stability metric                      |
| `difficulty`  | `REAL`          | FSRS inherent complexity metric            |
| `due`         | `DATETIME`      | Scheduled date and time for next review    |

### Review Table Map

Accessed under `review` list, each element being an object with two fields.

| Constant     | Type       | Description                           |
| :----------- | :--------- | ------------------------------------- |
| `reviewed`   | `DATETIME` | Date and time the evaluation occurred |
| `evaluation` | `TEXT`     | `Again`, `Hard`, `Good`, `Easy`       |

### Tag Table Map

Accessed under `tag` list, each element being an object with two fields.

> _Tags_ explicitly defined in the _item_ file’s front-matter are not included
> in this list

| Constant | Type   | Description              |
| :------- | :----- | ------------------------ |
| `name`   | `TEXT` | Name of the tag          |
| `parent` | `TEXT` | Name of the tag’s parent |

## Presentation API

Standard [Markdown] allows simple, static presentation, while [Typst] files or
`typst presentation` blocks (inside [Markdown] files) allows more complex or
interactive presentation.

### Typst Presentation (`typst presentation`)

Interactive Presentation API is provided under the form of a `titsh` [Typst]
module with interaction primitives injected by **Titsh**.

#### Interactivity Primitives

- `#titsh.action(id, payload)`: Triggers a state update
- `#titsh.draggable(id, body)`: Makes a block draggable
- `#titsh.input(var_name)`: Renders a text input linked to `state[var_name]`

#### Interactive Button Example

```typst presentation
#import "titsh"

#let count = state.at("count", default: 0)

#align(center)[
  #rect(fill: blue, radius: 5pt)[
    #link("action:increment")[
      Click count: #count
    ]
  ]
]
```

### Rhai Logic (`rhai presentation`)

For items that need complex state transitions but simple UIs, Rhai can provide
high-level components.

- `ui::choice(options, callback)`
- `ui::button(label, callback)`

## Evaluation API (`rhai evaluation`)

The evaluation block decides the final grade. It **must return** a `Grade`.

```rhai
if state.correct {
    return if chrono < 5.0 { Grade::Easy } else { Grade::Good };
}
return Grade::Again;
```

## Examples

### Balance Scale (Typst + Rhai)

This example uses Typst for the visual "Physics" and Rhai for the logic.

> An _item_ about equations could display each side as a plate of a balance
> scale, with factors as weights ; creating an intuition of the preservation of
> equality

```typst presentation
#import "titsh"

#let left = state.at("left", default: (10, 10, 2))
#let right = state.at("right", default: (24,))

#let l_mass = left.sum()
#let r_mass = right.sum()
#let angle = (r_mass - l_mass) * 1deg

#set align(center)
#rotate(angle)[
  // The Beam
  #line(start: (-150pt, 0pt), end: (150pt, 0pt), stroke: 5pt + black)
  
  // Plates
  #place(dx: -150pt)[
    #line(start: (0pt, 0pt), end: (0pt, 60pt), stroke: gray)
    #move(dy: 60pt, rect(width: 80pt, height: 10pt, fill: silver))
    // TODO Complete, with draggable weights, different colors for different variables
  ]
]
```

```rhai evaluation
if state.left.sum() == state.right.sum() {
    return Grade::Good;
}
return Grade::Again;
```

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
