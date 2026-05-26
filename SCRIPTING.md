---
lang: en-GB
---

<!--toc:start-->

- [Shared Context](#shared-context)
- [Presentation API (`rhai presentation`)](#presentation-api-rhai-presentation)
  - [Reactive UI](#reactive-ui)
  - [Inline Evaluation](#inline-evaluation)
  - [UI Components (`ui` module)](#ui-components-ui-module)
  - [Layout Helpers](#layout-helpers)
- [Evaluation API (`rhai evaluation`)](#evaluation-api-rhai-evaluation)
  - [Grading Variants](#grading-variants)
- [Built-in Helpers](#built-in-helpers)
- [Examples](#examples)
  - [Interactive Map](#interactive-map)

<!--toc:end-->

# Titsh Scripting API

Titsh uses [Rhai] for embedded logic. Scripts are split into two blocks:
`presentation` (UI) and `evaluation` (grading).

## Shared Context

These variables are available in both `presentation` and `evaluation` blocks.

| Variable   | Type        | Description                                     |
| :--------- | :---------- | :---------------------------------------------- |
| `item`     | `Object`    | `reviews`, `stability`, `difficulty`, `due`     |
| `params`   | `Map/Array` | Optional parameters for the current variant     |
| `state`    | `Map`       | Storage available to all blocks for the session |
| `reviews`  | `Array`     | Past reviews: `#{ date: "...", grade: "..." }`  |
| `chrono`   | `Float`     | Seconds elapsed since the item was displayed    |
| `date`     | `?`         | Current date                                    |
| `time`     | `?`         | Current time                                    |
| `datetime` | `?`         | Current date and time                           |

## Presentation API (`rhai presentation`)

The presentation block defines the interface. It **must return** a UI element.

### Reactive UI

The presentation block is re-evaluated whenever `state` changes (e.g., after a
click). Rhai returns the value of the last expression, or you can use an
explicit `return`.

```rhai presentation
if !state.started {
    return ui::button("Start", || state.started = true);
}

ui::text("Learning...")
```

### Inline Evaluation

For many items, you don't need a separate `evaluation` block. You can return a
`Grade` directly from a UI callback to finish the review.

```rhai presentation
ui::choice(["Correct", "Incorrect"], |picked| {
    if picked == "Correct" { return Grade::Good; }
    return Grade::Again;
})
```

### UI Components (`ui` module)

- `ui::text(content)`: Simple text display
- `ui::md(content)`: Renders Markdown
- `ui::image(path)`: Displays an image from item resources
- `ui::button(label, callback)`: Triggers a function when clicked
- `ui::input(label, var_name)`: Text input field. Updates `state[var_name]`
- `ui::choice(options, callback)`: Multiple choice buttons
- `ui::audio(path)`: Plays a sound from item resources

### Layout Helpers

- `ui::col([children])`: Vertical stack
- `ui::row([children])`: Horizontal stack
- `ui::center(child)`: Centers its content (horizontally and vertically)

## Evaluation API (`rhai evaluation`)

The evaluation block decides the final grade when `evaluate()` is called or a
timeout occurs. It **must return** a `Grade`.

### Grading Variants

- `Grade::Again` (Incorrect / Forgot)
- `Grade::Hard` (Correct, but struggled)
- `Grade::Good` (Correct, normal)
- `Grade::Easy` (Correct, very fast/obvious)
- `Grade::Skip` (No change to FSRS metrics)

## Built-in Helpers

| Function           | Description                                         |
| :----------------- | :-------------------------------------------------- |
| `distance(p1, p2)` | Euclidean distance between two points `[x, y]`      |
| `evaluate()`       | Triggers the `evaluation` block to decide the grade |
| `evaluate(grade)`  | Submits a specific `Grade` immediately              |
| `random()`         | Returns a random float between 0.0 and 1.0          |

## Examples

### Interactive Map

```rhai presentation
ui::col([
    ui::text("Where is " + params.country + "?"),
    ui::image("world_map.svg").on_click(|x, y| {
        state.click = [x, y];
        evaluate();
    })
])
```

```rhai evaluation
if distance(state.click, params.coords) < 10.0 {
    if time < 5.0 { return Grade::Easy; }
    if time < 25.0 { return Grade::Good; }
    return Grade::Hard;
}
return Grade::Again;
```

[Rhai]: https://rhai.rs
