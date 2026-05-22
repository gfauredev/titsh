---
lang: en-GB
---

<!-- > **Bold** Learning, education, memory or technical concepts\ -->
<!-- > _Italic_ Titsh specific concepts or features -->

# Titsh’s Simple & Lightweight Internal Database

## Item Table

| _Item_ field | Type | Description |
| ------------ | ---- | ----------- |

```sqlite
CREATE TABLE item(
);
```

## Tag Table

| _Tag_ field | Type | Description |
| ----------- | ---- | ----------- |

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
