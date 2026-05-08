#!/usr/bin/env bash
#
# Functional test for check-redirect-sunsets.sh.
# Sets up fixture markdown files with past, future, and missing sunset
# markers; runs the script against the fixture directory; asserts the
# output is correct.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/check-redirect-sunsets.sh"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

# Fixture: a page with a past sunset marker
mkdir -p "$FIXTURE/docs/plugins/test-plugin/how-to"
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/expired.md" <<'EOF'
---
title: Expired
redirect_from:
  - /old-path/
# redirect-sunset: 2020-01-01
---

# Expired
EOF

# Fixture: a page with a future sunset marker
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/future.md" <<'EOF'
---
title: Future
redirect_from:
  - /old-path/
# redirect-sunset: 2099-01-01
---

# Future
EOF

# Fixture: a page with no sunset marker
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/none.md" <<'EOF'
---
title: None
---

# None
EOF

# Run the script against the fixture
output=$("$SCRIPT" "$FIXTURE/docs/plugins" 2>&1) && rc=$? || rc=$?

# Assert: exit code is non-zero (findings exist)
if [[ "$rc" -eq 0 ]]; then
  echo "FAIL: expected non-zero exit code, got $rc"
  echo "Output: $output"
  exit 1
fi

# Assert: output mentions expired.md
if ! grep -q "expired.md" <<<"$output"; then
  echo "FAIL: expected 'expired.md' in output"
  echo "Output: $output"
  exit 1
fi

# Assert: output does NOT mention future.md
if grep -q "future.md" <<<"$output"; then
  echo "FAIL: future.md should not be flagged"
  echo "Output: $output"
  exit 1
fi

# Assert: output does NOT mention none.md
if grep -q "none.md" <<<"$output"; then
  echo "FAIL: none.md should not be flagged"
  echo "Output: $output"
  exit 1
fi

echo "PASS: check-redirect-sunsets.sh"
