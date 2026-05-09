"""Layer 1 structural tests for the plugin's ``hooks.json``.

The plugin ships ``ai-literacy-superpowers/hooks/hooks.json`` — a
declarative manifest that registers every hook (PreToolUse, Stop,
SessionStart, etc.) the plugin contributes to Claude Code. Hooks
either invoke an inline ``prompt`` (the model evaluates it on the
event) or run a ``command`` (typically a shell script under
``hooks/scripts/``).

Two failure modes worth catching at PR time:

1. The ``hooks.json`` file is malformed (invalid JSON, missing the
   top-level ``hooks`` map, or a hook entry missing required fields).
   The Claude Code loader rejects malformed manifests, but the
   failure surfaces only when a user installs and tries to use the
   plugin. PR-time validation catches it earlier.

2. A hook's ``command`` references a script path that does not exist.
   Same class of failure as the rename-without-callsite-update bug
   the command-wiring test catches for slash commands; this is the
   equivalent for hook scripts.

Both checks are pure structural — JSON parse + filesystem stat. No
LLM, no execution. Runs in milliseconds.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest


_PLUGIN_PATH = (
    Path(__file__).resolve().parent.parent.parent / "ai-literacy-superpowers"
)


# Recognised hook event names. Adding a new event type here is a
# deliberate decision (Claude Code occasionally introduces new ones);
# the test fails on any unrecognised event name to surface the
# question at PR time rather than letting it slip through.
KNOWN_HOOK_EVENTS = {
    "PreToolUse",
    "PostToolUse",
    "Stop",
    "SubagentStop",
    "SessionStart",
    "SessionEnd",
    "UserPromptSubmit",
    "PreCompact",
    "Notification",
}


@pytest.fixture(scope="module")
def hooks_manifest() -> dict:
    """Parse the hooks manifest. Fails the module if the file is
    malformed — every test below assumes a parseable manifest."""
    path = _PLUGIN_PATH / "hooks" / "hooks.json"
    if not path.exists():
        pytest.fail(f"hooks.json not found at {path!r}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        pytest.fail(f"hooks.json is invalid JSON: {exc}")


@pytest.mark.structural
class TestHooksManifestStructure:
    """The hooks.json manifest must follow the documented shape."""

    def test_has_top_level_hooks_map(self, hooks_manifest: dict):
        assert "hooks" in hooks_manifest, (
            "hooks.json must have a top-level 'hooks' key — the "
            "manifest format Claude Code expects"
        )
        assert isinstance(hooks_manifest["hooks"], dict), (
            "'hooks' must be a JSON object mapping event name to "
            "hook list"
        )

    def test_has_top_level_description(self, hooks_manifest: dict):
        """A description is non-essential to Claude Code but is the
        shipped manifest's documentation surface — the team has chosen
        to maintain one, so absence is a regression."""
        assert "description" in hooks_manifest, (
            "hooks.json should carry a top-level 'description' "
            "documenting what the manifest as a whole does"
        )
        assert isinstance(hooks_manifest["description"], str), (
            "'description' must be a string"
        )
        assert hooks_manifest["description"].strip(), (
            "'description' must be non-empty"
        )

    def test_event_names_are_recognised(self, hooks_manifest: dict):
        """Each top-level key under ``hooks`` should be a recognised
        Claude Code event name. Unknown names are either typos or
        upstream additions worth surfacing at PR time."""
        unknown = [
            name
            for name in hooks_manifest["hooks"]
            if name not in KNOWN_HOOK_EVENTS
        ]
        assert not unknown, (
            f"hooks.json registers hooks for unknown events: {unknown}. "
            "Either Claude Code added a new event type (update "
            f"KNOWN_HOOK_EVENTS in this file) or a typo crept in. "
            f"Recognised events: {sorted(KNOWN_HOOK_EVENTS)}."
        )


@pytest.mark.structural
class TestHookEntryStructure:
    """Every hook entry under every event must have the expected
    shape — matcher + hooks list of typed entries with required
    fields per type."""

    def test_each_event_has_a_list_of_hook_groups(
        self, hooks_manifest: dict
    ):
        for event, groups in hooks_manifest["hooks"].items():
            assert isinstance(groups, list), (
                f"hooks.{event} must be a list; got {type(groups).__name__}"
            )

    def test_each_group_has_matcher_and_hooks(
        self, hooks_manifest: dict
    ):
        broken: list[str] = []
        for event, groups in hooks_manifest["hooks"].items():
            for index, group in enumerate(groups):
                if "matcher" not in group:
                    broken.append(
                        f"hooks.{event}[{index}] missing 'matcher'"
                    )
                if "hooks" not in group:
                    broken.append(
                        f"hooks.{event}[{index}] missing 'hooks' list"
                    )
                elif not isinstance(group["hooks"], list):
                    broken.append(
                        f"hooks.{event}[{index}].hooks must be a list"
                    )
        assert not broken, "Malformed hook groups: " + "\n  ".join(
            ["", *broken]
        )

    def test_each_hook_entry_has_required_fields(
        self, hooks_manifest: dict
    ):
        """Each entry inside a group must have a ``type`` and a
        ``timeout``, plus the type-specific payload field
        (``command`` for ``type=command``, ``prompt`` for
        ``type=prompt``)."""
        broken: list[str] = []
        for event, groups in hooks_manifest["hooks"].items():
            for group_idx, group in enumerate(groups):
                for hook_idx, hook in enumerate(group.get("hooks", [])):
                    location = (
                        f"hooks.{event}[{group_idx}].hooks[{hook_idx}]"
                    )
                    if "type" not in hook:
                        broken.append(f"{location} missing 'type'")
                        continue
                    if "timeout" not in hook:
                        broken.append(f"{location} missing 'timeout'")
                    htype = hook["type"]
                    if htype == "command" and "command" not in hook:
                        broken.append(
                            f"{location} type=command but no 'command'"
                        )
                    elif htype == "prompt" and "prompt" not in hook:
                        broken.append(
                            f"{location} type=prompt but no 'prompt'"
                        )
                    elif htype not in ("command", "prompt"):
                        broken.append(
                            f"{location} unknown type {htype!r}"
                        )
        assert not broken, "Malformed hook entries: " + "\n  ".join(
            ["", *broken]
        )


@pytest.mark.structural
class TestHookCommandsResolve:
    """Every ``command`` hook must reference a script path that
    actually exists on disk. The same rename-without-callsite-update
    failure class the command-wiring test catches for slash commands,
    but for hook scripts."""

    # Match a command-style hook command of the form:
    #   bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh
    # and capture the script path relative to the plugin root.
    _COMMAND_RE = re.compile(
        r"\$\{CLAUDE_PLUGIN_ROOT\}/(?P<rel_path>[A-Za-z0-9_./-]+\.sh)"
    )

    def test_every_command_script_exists(self, hooks_manifest: dict):
        broken: list[str] = []
        for event, groups in hooks_manifest["hooks"].items():
            for group_idx, group in enumerate(groups):
                for hook_idx, hook in enumerate(group.get("hooks", [])):
                    if hook.get("type") != "command":
                        continue
                    command = hook.get("command", "")
                    match = self._COMMAND_RE.search(command)
                    if not match:
                        # Command does not reference a script path
                        # under CLAUDE_PLUGIN_ROOT — could be a
                        # one-liner using shell builtins; skip rather
                        # than flag as broken.
                        continue
                    rel_path = match.group("rel_path")
                    full_path = _PLUGIN_PATH / rel_path
                    if not full_path.exists():
                        broken.append(
                            f"hooks.{event}[{group_idx}].hooks"
                            f"[{hook_idx}] references "
                            f"${{CLAUDE_PLUGIN_ROOT}}/{rel_path}, "
                            f"which does not exist"
                        )
        assert not broken, (
            "Hook command(s) reference missing script(s):"
            + "\n  ".join(["", *broken])
        )
