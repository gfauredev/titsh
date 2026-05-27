---
lang: en-GB
---

<!--toc:start-->

- [Shared Context](#shared-context)
- [Parametric Data](#parametric-data)
  - [Presentation API (`rhai presentation`)](#presentation-api-rhai-presentation)
  - [Reactive UI](#reactive-ui)
  - [Inline Evaluation](#inline-evaluation)
  - [UI Components (`ui` module)](#ui-components-ui-module)
  - [Layout Helpers](#layout-helpers)
  - [Transformations & Styling (Chainable)](#transformations-styling-chainable)
  - [Coordinate System & Units](#coordinate-system-units)
  - [Interaction Events (Advanced)](#interaction-events-advanced)
- [Evaluation API (`rhai evaluation`)](#evaluation-api-rhai-evaluation)
  - [Grading Variants](#grading-variants)
- [Built-in Helpers](#built-in-helpers)
- [Examples](#examples)
  - [Interactive Map](#interactive-map)
  - [Balance Scale (Equation Intuition)](#balance-scale-equation-intuition)

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

## Parametric Data

For parametric items, `params` is the object associated with the current variant
in your data file.

**Example Data (`countries.json`):**

```json
{
  "France": {
    "capital": "Paris",
    "border": [[10, 20], [15, 25], [10, 25]]
  }
}
```

When learning the "France" variant, `params.capital` will be `"Paris"` and
`params.border` will be the array of points. This allows you to name your fields
whatever makes sense for your item, making your scripts more readable.

### Presentation API (`rhai presentation`)

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

Most components take a **styling map** as their first argument, mirroring
Typst's named parameters.

- `ui::text(content)`: Renders text.
- `ui::md(content)`: Renders Markdown.
- `ui::image(path)`: Displays an image from item resources.
- `ui::rect(#{ width, height, fill, stroke, radius })`: Renders a rectangle.
- `ui::circle(#{ radius, fill, stroke })`: Renders a circle.
- `ui::line(p1, p2, #{ stroke })`: Renders a line between `[x, y]` and `[x, y]`.
- `ui::poly(points, #{ fill, stroke })`: Renders a polygon from point array.

### Layout Helpers

Mirroring Typst's layout engine:

- `ui::stack(dir, [children])`: Stacks elements in a direction.
  - `dir` constants: `ltr` (left-to-right), `ttb` (top-to-bottom).
- `ui::align(alignment, child)`: Positions a child within its parent.
  - `alignment` constants: `left`, `center`, `right`, `top`, `bottom` or
    combinations like `top + right`.
- `ui::pad(#{ top, right, bottom, left, rest }, child)`: Adds padding around a
  child.

### Transformations

Transformations are functional and wrap a child element:

- `ui::move(#{ dx, dy }, child)`: Shifts the child by an offset.
- `ui::rotate(angle, child)`: Rotates the child (angle in degrees).
- `ui::scale(factor, child)`: Scales the child.

### Interaction & Logic

- `ui::button(label, callback)`: Simple button.
- `ui::input(label, var_name)`: Updates `state[var_name]`.
- `ui::choice(options, callback)`: Multiple choice buttons.

Every component supports event listeners via chaining: `.on_click(fn)`,
`.on_press(fn)`, `.on_release(fn)`, `.on_drag(fn)`.

### Units & Dimensions

- `42`: Raw pixels (number).
- `"50%"`: Percentage of parent container (string).
- `1.fr`: Fractional units for distribution in stacks.

### Coordinate System & Units

- **Origin**: (0, 0) is the top-left corner of the item's display area or its
  parent group.
- **Units**: Pixels.
- **Rotation**: Degrees, clockwise (0 is right, 90 is down).
- **Z-Index**: Determined by the order in arrays (last is on top) or via
  `ui::stack`.

### Interaction Events (Advanced)

Components can respond to low-level input events:

- `.on_click(callback)`: Triggered on a full click/tap
- `.on_press(callback)`: Triggered as soon as pressed (receives `[x, y]`)
- `.on_release(callback)`: Triggered when released
- `.on_hover(is_hovered)`: Triggered when mouse enters/leaves
- `.on_drag(callback)`: Triggered when moved while pressed. The callback
  receives `[dx, dy]` (movement since last frame) and the current `[x, y]`
  relative to the component.

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

| Function             | Description                                         |
| :------------------- | :-------------------------------------------------- |
| `distance(p1, p2)`   | Euclidean distance between two points `[x, y]`      |
| `contains(poly, p)`  | `true` if point `p` is inside the polygon `poly`    |
| `clamp(v, min, max)` | Clamps a value between min and max                  |
| `lerp(a, b, t)`      | Linear interpolation between `a` and `b` by `t`     |
| `evaluate()`         | Triggers the `evaluation` block to decide the grade |
| `evaluate(grade)`    | Submits a specific `Grade` immediately              |
| `random()`           | Returns a random float between 0.0 and 1.0          |

## Examples

### Interactive Map

```rhai presentation
ui::stack(ttb, [
    ui::text("Where is " + params.country + "?"),
    ui::image("world_map.svg").on_click(|pos| {
        state.click = pos;
        evaluate();
    })
])
```

```rhai evaluation
if contains(params.border, state.click) {
    if chrono < 5.0 { return Grade::Easy; }
    if chrono < 25.0 { return Grade::Good; }
    return Grade::Hard;
}
return Grade::Again;
```

### Balance Scale (Equation Intuition)

This example demonstrates how to use `stack`, `align`, and `move` in a
functional style similar to Typst.

```rhai presentation
# Initialize state if first run
if state.left == () {
    state.left = [10, 10, 2, 2, 2]; # 2x + 6
    state.right = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]; # 24
}

# Calculate balance tilt
let left_mass = state.left.reduce(|a, b| a + b, 0);
let right_mass = state.right.reduce(|a, b| a + b, 0);
let angle = (right_mass - left_mass) * 2.0;

# Helper to render a weight
fn weight(mass, list_name, index) {
    let color = if mass > 5 { "orange" } else { "lightblue" };
    let label = if mass > 5 { "x" } else { mass.to_string() };
    
    return ui::stack(center, [
        ui::rect(#{
            width: 30,
            height: 30,
            fill: color,
            stroke: 1 + black, # Typst-style stroke shorthand
            radius: 4
        }),
        ui::text(label)
    ]).on_drag(|delta, pos| {
        state[list_name].remove(index);
    });
}

ui::align(center, 
    ui::rotate(angle, [
        # The beam
        ui::line([-150, 0], [150, 0], #{ stroke: 5 + black }),
        
        # Left plate
        ui::move(#{ dx: -150 }, [
            ui::line([0, 0], [0, 60], #{ stroke: 2 + gray }),
            ui::move(#{ dx: -40, dy: 60 }, ui::rect(#{ width: 80, height: 10, fill: silver })),
            ui::move(#{ dx: -40, dy: 30 }, 
                ui::pad(#{ rest: 5 }, ui::stack(ltr, state.left.map(|m, i| weight(m, "left", i))))
            )
        ]),
        
        # Right plate
        ui::move(#{ dx: 150 }, [
            ui::line([0, 0], [0, 60], #{ stroke: 2 + gray }),
            ui::move(#{ dx: -40, dy: 60 }, ui::rect(#{ width: 80, height: 10, fill: silver })),
            ui::move(#{ dx: -40, dy: 30 }, 
                ui::pad(#{ rest: 5 }, ui::stack(ltr, state.right.map(|m, i| weight(m, "right", i))))
            )
        ])
    ])
)
```

[Rhai]: https://rhai.rs
