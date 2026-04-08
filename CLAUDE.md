# [CLAUDE.md](http://CLAUDE.md)

This vault is an LLM-maintained personal knowledge and RAG system — a persistent, compounding wiki between you and the raw sources.

## Role

- **LLM**: librarian, compiler, analyst, maintainer.
- **User**: curates sources, directs analysis, asks questions, makes final judgments.

## Session Start

Read these first:

1. `wiki/index.md` — what pages exist and how they connect.
2. The last 5–10 entries of `_compile_log.md` — what was recently compiled.

## Three Layers

- `raw/` — immutable source material (markdown, text, PDF extracts, web clippings, transcripts).
  - `raw/assets/` — images, diagrams, screenshots. Obsidian attachment folder points here.
- `wiki/` — LLM-generated knowledge layer (sources, concepts, syntheses).
  - `wiki/index.md` — catalog of all pages with links, organized by type.
- `_compile_log.md` — append-only chronological record of ingests.

## Three Object Types

- **Source** (`wiki/sources/`) — compiled from one raw input. Preserves provenance, extracts claims.
- **Concept** (`wiki/concepts/`) — reusable idea or pattern across sources. Main retrieval layer.
- **Synthesis** (`wiki/syntheses/`) — integrated analysis across sources and concepts.

## Three Operations

### Compile (`/compile`)

Transform raw/ into wiki/. Details in `.claude/skills/compile/SKILL.md`.

- Detect new/changed files via sha256
- Create/update source, concept, and synthesis pages
- Verify all `[[links]]` resolve to existing pages
- Update `wiki/index.md` and append to `_compile_log.md`

### Query (`/query`)

Answer from the vault. Details in `.claude/skills/query/SKILL.md`.

- Read index → identify relevant pages → recursively follow `[[wiki links]]` (depth 2, max 15 pages)
- Cite sources with `[[wiki links]]`, distinguish facts from inference
- Good answers get filed back as synthesis pages

### Lint (`/graph-lint`)

Health-check the wiki. Details in `.claude/skills/graph-lint/SKILL.md`.

## First-Time Setup

If `wiki/index.md` doesn't exist and `_compile_log.md` is empty, treat all raw/ files as new and compile everything.

## Principles

- Include `type`, `topic`, `concepts` in frontmatter. Sources also get `source_file`, `checksum`, `updated`.
- Topics can overlap — use lists in frontmatter, link across topics, add shared concept pages.
- Check existing concepts (including aliases) before creating new ones. Split broad ones, merge duplicates.
- Record provenance: raw filename, original URL when available. Never fabricate.
- Distinguish source facts from LLM inference. Preserve contradictions. Note missing data.
- Bullets over paragraphs. Keep pages dense, structured, link-rich.
- Use `[[wiki links]]` for cross-references. Keep content readable in Obsidian.

## Compile Log Format

`_compile_log.md` is append-only. Each entry is one line:

```
## [2026-04-06] new | raw/filename.md → wiki-page-name | sha256:abc123...
```

Parseable with `grep "^## \[" _compile_log.md | tail -5`.