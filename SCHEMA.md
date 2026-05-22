---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

# Titsh’s Simple & Lightweight Internal Database

> For each field, write a paragraph with its name, type, description and
> argument why it is needed

## Item Table

```sqlite
CREATE TABLE item(
);
```

## Tag Table

```sqlite
CREATE TABLE tag(
);
```

```sqlite
CREATE TABLE tagging(
  -- Many-to-many relationship
  -- between items and tags
);
```

The database only stores _tags_ created or modified by the user in their own
`tag` row, not _tags_ predefined in _items_ files. These, however, could be
cached elsewhere if needed for performance.
