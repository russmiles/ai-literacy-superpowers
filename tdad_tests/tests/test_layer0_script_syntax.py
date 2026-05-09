"""Layer 0: bash syntax check for every shell script the plugin ships.

The plugin ships a substantial set of shell scripts: standalone
scripts under ``ai-literacy-superpowers/scripts/`` (plus its ``lib/``
subdirectory) and per-event hook scripts under
``ai-literacy-superpowers/hooks/scripts/``. Any of these can hit a
production user's machine if invoked by a hook or referenced from a
command. A syntax error in one of them — a missing ``done`` after a
loop, an unbalanced quote, a stray ``$`` — is a runtime failure that
the user sees without warning.

Layer 0 already runs full integration tests for the three reflection-
log scripts that have substantive logic (the bash test suite under
``tdad_tests/layer0_deterministic/``). What that suite does *not*
cover is the rest of the shipped scripts — the ones whose body is
"call gh, format output, exit" and whose primary failure mode is
being syntactically broken rather than producing wrong output.

This module fills that gap. For every ``.sh`` file the plugin ships,
``bash -n <file>`` parses the script without executing it and exits
non-zero on any syntax error. Equivalent to a compile-only build for
shell. Catches the failure mode at PR time, before the script ever
runs.

Cost: $0, milliseconds per script. Coverage: every shipped shell
script. Granularity: per-script — failure points at the specific
file and line.
"""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import pytest


_PLUGIN_PATH = (
    Path(__file__).resolve().parent.parent.parent / "ai-literacy-superpowers"
)


def _all_shell_scripts() -> list[Path]:
    """Find every ``.sh`` file the plugin ships.

    Three locations cover the current plugin layout:

    - ``scripts/`` for standalone scripts (badge updates, cache sync).
    - ``scripts/lib/`` for sourceable libraries.
    - ``hooks/scripts/`` for per-event hook scripts.

    Returns absolute paths so the parametrise IDs render usefully and
    each test can dispatch the script without further resolution.
    """
    if not _PLUGIN_PATH.is_dir():
        return []
    candidates: list[Path] = []
    for directory in (
        _PLUGIN_PATH / "scripts",
        _PLUGIN_PATH / "scripts" / "lib",
        _PLUGIN_PATH / "hooks" / "scripts",
    ):
        if directory.is_dir():
            candidates.extend(sorted(directory.glob("*.sh")))
    return candidates


_ALL_SCRIPTS = _all_shell_scripts()


@pytest.fixture(scope="session")
def bash_executable() -> str:
    """Locate the system bash; fail informatively if it is missing."""
    bash = shutil.which("bash")
    if not bash:
        pytest.fail(
            "bash not found on PATH. Layer 0 script-syntax checks "
            "require a POSIX shell with bash."
        )
    return bash


@pytest.mark.structural
class TestShellScriptSyntax:
    """Every shipped shell script must parse cleanly under ``bash -n``."""

    def test_at_least_one_script_discovered(self):
        assert _ALL_SCRIPTS, (
            "No shell scripts discovered for syntax checking. "
            "Plugin layout may have changed; check "
            "_all_shell_scripts() in this file."
        )

    @pytest.mark.parametrize(
        "script",
        _ALL_SCRIPTS,
        ids=lambda script: script.name,
    )
    def test_script_parses(
        self, script: Path, bash_executable: str
    ) -> None:
        """Run ``bash -n`` on the script. Non-zero exit means a
        syntax error; the captured output names the file and line.

        ``bash -n`` performs syntactic validation only — no commands
        execute, no side effects. This is the compile-only equivalent
        for shell.
        """
        result = subprocess.run(
            [bash_executable, "-n", str(script)],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            pytest.fail(
                f"{script.name} failed bash syntax check "
                f"(exit {result.returncode}).\n"
                f"--- stderr ---\n{result.stderr}\n"
                f"--- stdout ---\n{result.stdout}"
            )
