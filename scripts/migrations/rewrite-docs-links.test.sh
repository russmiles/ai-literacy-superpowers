#!/usr/bin/env bash
#
# Functional test for rewrite-docs-links.sh.
# Sets up a fixture move-map and a tree of markdown files containing
# both old-path and unrelated links; runs the script; asserts the
# old-path links are rewritten and unrelated links are untouched.
# Also asserts idempotency: running the script twice produces the same
# output as running it once.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/rewrite-docs-links.sh"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

# Fixture move-map: TSV with two rows
cat >"$fixture/move-map.tsv" <<'EOF'
docs/plugins/test-plugin/research-a-model-card.md	docs/plugins/test-plugin/how-to/research-a-model-card.md
docs/plugins/test-plugin/agents.md	docs/plugins/test-plugin/reference/agents.md
EOF

# Fixture markdown files: a mix of links to be rewritten and untouched
mkdir -p "$fixture/docs/plugins/test-plugin"
cat >"$fixture/sample.md" <<'EOF'
See [Research a Model Card](docs/plugins/test-plugin/research-a-model-card.md)
and [Agents](docs/plugins/test-plugin/agents.md). Unrelated:
[README](README.md) and [Other](docs/plugins/other-plugin/agents.md).
EOF

cat >"$fixture/no-matches.md" <<'EOF'
Just a [README](README.md) link, nothing to rewrite.
EOF

# Run the script against the fixture
cd "$fixture"
"$script" move-map.tsv

# Assert: links in sample.md are rewritten
if ! grep -qF "docs/plugins/test-plugin/how-to/research-a-model-card.md" sample.md; then
  echo "FAIL: research-a-model-card.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi
if ! grep -qF "docs/plugins/test-plugin/reference/agents.md" sample.md; then
  echo "FAIL: agents.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi

# Assert: unrelated links in sample.md are untouched
if ! grep -qF "[README](README.md)" sample.md; then
  echo "FAIL: README link was clobbered in sample.md"
  exit 1
fi
if ! grep -qF "docs/plugins/other-plugin/agents.md" sample.md; then
  echo "FAIL: other-plugin/agents.md link was clobbered in sample.md"
  exit 1
fi

# Assert: no-matches.md is unchanged
if ! grep -qF "[README](README.md) link" no-matches.md; then
  echo "FAIL: no-matches.md was modified unexpectedly"
  exit 1
fi

# Assert: idempotency — running again produces no change
if command -v md5sum >/dev/null 2>&1; then
  checksum_cmd="md5sum"
else
  checksum_cmd="md5 -r"
fi

md5_before=$(eval "$checksum_cmd" sample.md no-matches.md | sort)
"$script" move-map.tsv
md5_after=$(eval "$checksum_cmd" sample.md no-matches.md | sort)

if [[ "$md5_before" != "$md5_after" ]]; then
  echo "FAIL: script is not idempotent"
  echo "Before: $md5_before"
  echo "After:  $md5_after"
  exit 1
fi

echo "PASS: rewrite-docs-links.sh"
