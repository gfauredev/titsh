---
lang: en-GB
---

# Titsh Scripting API

Titsh uses [Rhai] for embedded logic. Scripts are split into two blocks:
`presentation` (UI) and `evaluation` (grading).

## Shared Context

These variables are available in both `presentation` and `evaluation` blocks.

| Variable  | Type        | Description                                                                            |
| :-------- | :---------- | :------------------------------------------------------------------------------------- |
| `item`    | `Object`    | Metadata: `reviews`, `stability`, `difficulty`, `retrievability`.                      |
| `params`  | `Map/Array` | Parameters for the current variant (if parametric).                                    |
| `state`   | `Map`       | Persistent storage for the current session. Use it to pass data from UI to evaluation. |
| `history` | `Array`     | List of past reviews: `#{ date: "...", grade: "..." }`.                                |
| `time`    | `Float`     | Seconds elapsed since the item was displayed.                                          |

## Presentation API (`rhai presentation`)

The presentation block should return a UI element or use the `ui` module to
build the interface.

### UI Components (`ui` module)

- **`ui::text(content)`**: Simple text display.
- **`ui::md(content)`**: Renders Markdown.
- **`ui::image(path)`**: Displays an image from item resources.
- **`ui::button(label, callback)`**: Triggers a function when clicked.
- **`ui::input(label, var_name)`**: Text input field. Updates `state[var_name]`.
- **`ui::choice(options, callback)`**: Multiple choice buttons.
- **`ui::audio(path)`**: Plays a sound.

### Layout Helpers

- **`ui::col([children])`**: Vertical stack.
- **`ui::row([children])`**: Horizontal stack.
- **`ui::center(child)`**: Centers its content.

### Events

Most components support chaining event handlers:

- `.on_click(|x, y| { ... })`
- `.on_submit(|value| { ... })`

## Built-in Helpers

| Function           | Description                                                              |
| :----------------- | :----------------------------------------------------------------------- |
| `distance(p1, p2)` | Calculates the Euclidean distance between two points `[x, y]`.           |
| `evaluate()`       | Triggers the `evaluation` block to decide the grade.                     |
| `evaluate(grade)`  | Submits a specific `Grade` immediately, skipping the `evaluation` block. |
| `random()`         | Returns a random float between 0.0 and 1.0.                              |
| `random(min, max)` | Returns a random float between `min` and `max`.                          |

## Evaluation API (`rhai evaluation`)

Decides the final grade. Can be triggered manually by calling `evaluate()` in
presentation or automatically (e.g. on timeout).

### Grading

The block must return one of these values:

- `Grade::Again` (Incorrect / Forgot)
- `Grade::Hard` (Correct, but struggled)
- `Grade::Good` (Correct, normal)
- `Grade::Easy` (Correct, very fast/obvious)
- `Grade::Skip` (No change to FSRS metrics)

## Examples

### Simple Flashcard

```rhai presentation
if state.show_answer {
    ui::col([
        ui::text(params.back),
        ui::row([
            ui::button("Again", || evaluate(Grade::Again)),
            ui::button("Hard", || evaluate(Grade::Hard)),
            ui::button("Good", || evaluate(Grade::Good)),
            ui::button("Easy", || evaluate(Grade::Easy))
        ])
    ])
} else {
    ui::col([
        ui::text(params.front),
        ui::button("Show Answer", || state.show_answer = true)
    ])
}
```

### Multiple Choice

```rhai presentation
ui::col([
    ui::md("# " + params.question),
    ui::choice(params.options, |picked| {
        state.answer = picked;
        evaluate();
    })
])
```

```rhai evaluation
if state.answer == params.correct {
    if time < 5.0 { return Grade::Easy; }
    return Grade::Good;
}
return Grade::Again;
```

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
// Distance check helper
if distance(state.click, params.coords) < 10.0 {
    return Grade::Good;
}
return Grade::Again;
```

[Rhai]: https://rhai.rs
