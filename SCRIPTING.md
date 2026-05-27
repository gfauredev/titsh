---
lang: en-GB
---

<!--toc:start-->

- [Shared Context](#shared-context)
- [Presentation API](#presentation-api)
  - [Typst Presentation (`typst presentation`)](#typst-presentation-typst-presentation)
    - [Interactivity Primitives](#interactivity-primitives)
    - [Example: Interactive Button](#example-interactive-button)
  - [Rhai Logic (`rhai presentation`)](#rhai-logic-rhai-presentation)
- [Evaluation API (`rhai evaluation`)](#evaluation-api-rhai-evaluation)
- [Examples](#examples)
  - [Balance Scale (Typst + Rhai)](#balance-scale-typst-rhai)

<!--toc:end-->

# Titsh Scripting

Titsh uses a hybrid architecture:

- **Markdown** for standard text.
- **Typst** for layout, math, and drawing.
- **Rhai** for state management and evaluation logic.

## Shared Context

These variables are available in both **Typst** and **Rhai** blocks.

| Variable | Description                                                      |
| :------- | :--------------------------------------------------------------- |
| `state`  | A mutable map for session data (Rhai can write, Typst can read). |
| `params` | Parameter values for the current variant.                        |
| `chrono` | Seconds elapsed since the item was displayed.                    |
| `item`   | Metadata: `reviews`, `stability`, `difficulty`, `due`.           |

## Presentation API

The presentation is handled either by standard Markdown prose or by a
`typst presentation` block.

### Typst Presentation (`typst presentation`)

The entire Typst layout engine is available. Titsh injects a `titsh` module with
interactive primitives.

#### Interactivity Primitives

- `#titsh.action(id, payload)`: Triggers a state update.
- `#titsh.draggable(id, body)`: Makes a block draggable.
- `#titsh.input(var_name)`: Renders a text input linked to `state[var_name]`.

#### Example: Interactive Button

```typst
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
    // ...
  ]
]
```

```rhai evaluation
if state.left.sum() == state.right.sum() {
    return Grade::Good;
}
return Grade::Again;
```

[Rhai]: https://rhai.rs
[Typst]: https://typst.app
