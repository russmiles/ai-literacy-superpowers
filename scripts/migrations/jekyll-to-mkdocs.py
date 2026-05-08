#!/usr/bin/env python3
"""
jekyll-to-mkdocs.py — one-shot migration from Jekyll just-the-docs to MkDocs Material.

Walks every .md file under docs/ and:

  1. Converts Liquid {% link path/to/page.md %} tags to relative markdown
     paths from the source file. mkdocs cannot interpret Liquid, so these
     would otherwise fail the build.

  2. Extracts redirect_from frontmatter lists. Emits a YAML map suitable
     for the mkdocs-redirects plugin (relative-source-path -> relative-
     source-path) on stdout.

The script does NOT strip Jekyll-specific frontmatter (parent, grand_parent,
nav_order, has_children, layout, nav_label) because mkdocs ignores unknown
frontmatter fields. Removing them is unnecessary churn.

Usage:
    python3 scripts/migrations/jekyll-to-mkdocs.py [--apply] [--print-redirects]

Without --apply the script reports what it would change. With --apply it
writes the changes in place. With --print-redirects it emits the redirect
map YAML on stdout (separate concern from the in-place rewrites).
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

DOCS_DIR = Path("docs")

LIQUID_LINK = re.compile(r"\{%\s*link\s+(\S+?)\s*%\}")

REDIRECT_BLOCK = re.compile(
    r"^redirect_from:\s*\n((?:\s*-\s*.+\n)+)",
    re.MULTILINE,
)

FRONTMATTER_BOUND = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def relative_link(source_path: Path, target_docs_path: str) -> str:
    """Compute a relative markdown link from `source_path` to docs/`target_docs_path`."""
    target = (DOCS_DIR / target_docs_path).resolve()
    source_dir = source_path.parent.resolve()
    rel = os.path.relpath(target, source_dir)
    return rel


def convert_liquid(content: str, source_path: Path) -> tuple[str, int]:
    """Replace every {% link X %} with a relative path from source_path to docs/X."""
    count = 0

    def replace(match: re.Match) -> str:
        nonlocal count
        target_docs_path = match.group(1)
        count += 1
        return relative_link(source_path, target_docs_path)

    new_content = LIQUID_LINK.sub(replace, content)
    return new_content, count


def extract_redirects(content: str, source_docs_path: str) -> list[tuple[str, str]]:
    """Pull each `redirect_from:` URL out of frontmatter, return (old_url, source_docs_path) pairs.

    `source_docs_path` is relative to docs/ (e.g. 'plugins/model-cards/reference/agents.md').

    The mkdocs-redirects plugin expects `redirect_maps: <old>: <new>` where both
    sides are relative-to-docs paths to .md files. So we convert each redirect
    URL like `/plugins/model-cards/agents/` to `plugins/model-cards/agents.md`
    (stripping leading slash, stripping trailing slash, adding .md suffix), and
    each `.html` variant the same way.
    """
    fm_match = FRONTMATTER_BOUND.match(content)
    if not fm_match:
        return []
    fm = fm_match.group(1)
    rd_match = REDIRECT_BLOCK.search(fm)
    if not rd_match:
        return []
    block = rd_match.group(1)
    old_urls = [
        re.sub(r"^\s*-\s*", "", line).strip()
        for line in block.splitlines()
        if line.strip()
    ]
    redirects: list[tuple[str, str]] = []
    for url in old_urls:
        # Normalise: strip leading slash, strip trailing slash or .html
        normalised = url.strip("/")
        if normalised.endswith(".html"):
            normalised = normalised[: -len(".html")] + ".md"
        else:
            normalised = normalised + ".md"
        redirects.append((normalised, source_docs_path))
    return redirects


def iter_doc_files() -> list[Path]:
    out: list[Path] = []
    for p in DOCS_DIR.rglob("*.md"):
        rel = p.relative_to(DOCS_DIR).as_posix()
        # Skip excluded subtrees that mkdocs.yml's exclude_docs would also drop
        if rel.startswith("superpowers/") or rel == "_template.md":
            continue
        # Skip per-plugin _template.md files (we keep them at root only)
        if rel.endswith("/_template.md"):
            continue
        out.append(p)
    return sorted(out)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write changes in place")
    parser.add_argument(
        "--print-redirects",
        action="store_true",
        help="emit the redirect map YAML on stdout (does not modify files)",
    )
    args = parser.parse_args()

    files = iter_doc_files()
    total_link_conversions = 0
    files_modified = 0
    all_redirects: list[tuple[str, str]] = []

    for path in files:
        content = path.read_text()
        rel_path = path.relative_to(DOCS_DIR).as_posix()

        new_content, n = convert_liquid(content, path)
        if n > 0:
            total_link_conversions += n
            files_modified += 1
            if args.apply:
                path.write_text(new_content)

        # Extract redirects (regardless of apply mode — emitting them is a
        # separate output that the user pipes to mkdocs.yml).
        redirects = extract_redirects(content, rel_path)
        all_redirects.extend(redirects)

    if args.print_redirects:
        print("# Auto-generated by jekyll-to-mkdocs.py — paste under plugins:redirects:redirect_maps")
        for old, new in sorted(all_redirects):
            # YAML-quote keys that contain reserved characters or special tokens
            print(f"        {old}: {new}")
    else:
        verb = "would convert" if not args.apply else "converted"
        print(
            f"Liquid links: {verb} {total_link_conversions} tag(s) across {files_modified} file(s)",
            file=sys.stderr,
        )
        print(f"Redirects extracted: {len(all_redirects)} pair(s)", file=sys.stderr)
        if not args.apply:
            print("(re-run with --apply to write changes; --print-redirects to emit YAML)", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
