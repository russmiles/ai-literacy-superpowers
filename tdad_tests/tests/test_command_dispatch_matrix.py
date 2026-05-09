"""Phase 3 — orchestration command dispatch matrix.

Phase 1 catches the failure mode "command references X, X doesn't
exist" — the rename-without-callsite-update class. Phase 3 catches
the inverse: "command was supposed to dispatch Y and doesn't anymore."
The two tests have orthogonal coverage.

Phase 3's contribution is a *matrix*: each of the 7 orchestration
commands declares the agents and skills it must dispatch. The test
parametrises across the matrix and asserts each declared dispatch is
present in the command body. If a future refactor removes a dispatch
without updating its callers, the test fails — naming the specific
command and the specific missing dispatch.

Why per-command expected-dispatches rather than a generic check?
Because an orchestration command's *value* is the specific agents it
chains together. ``/harness-audit`` is supposed to dispatch
harness-discoverer, harness-enforcer, *and* harness-auditor. If a
refactor accidentally removes the third, Phase 1 stays green (every
remaining reference resolves) but the command's behaviour silently
degrades. The matrix locks in the contract.

The matrix is hand-authored from the current command bodies. Adding
a new dispatch to an orchestration command means the agent gets a new entry; the
matrix follows the prose. Both directions of drift (prose loses a
dispatch, prose gains one) are caught — the former by failing
assertions, the latter by reading the test alongside any PR that
adds dispatches.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


# Each entry is ``(command_name, expected_agents, expected_skills)``.
#
# - ``expected_agents`` lists the *agents* the command must dispatch
#   somewhere in its body. The match is on backticked or
#   un-backticked agent name immediately before the word "agent".
# - ``expected_skills`` lists the *skills* the command must invoke or
#   reference as load-bearing. Some orchestration commands (notably
#   ``/harness-sync``) use a skill rather than an agent as their
#   primary work-horse; this captures those.
#
# Commands intentionally absent from the matrix:
#
# - ``/superpowers-init`` — orchestrates other slash commands rather
#   than dispatching agents directly. Its dispatches are commands; the
#   command-to-command wiring is a different surface (Phase 1's
#   generic check catches missing skill references; per-command
#   command-call expectations would be a Phase 3.5 if we ever need
#   them).
DISPATCH_MATRIX: list[tuple[str, list[str], list[str]]] = [
    # /harness-audit chains three agents to verify harness state.
    # Removing any of them silently weakens the audit.
    (
        "harness-audit",
        ["harness-discoverer", "harness-enforcer", "harness-auditor"],
        [],
    ),
    # /governance-audit is a single-agent dispatcher.
    ("governance-audit", ["governance-auditor"], []),
    # /harness-init dispatches the discoverer up front; the guided
    # init flow that follows is conversational and doesn't dispatch
    # further agents directly.
    ("harness-init", ["harness-discoverer"], []),
    # /harness-sync is the special case — its primary work-horse is
    # the harness-audit-engine *skill*, not an agent. The matrix
    # captures that.
    ("harness-sync", [], ["harness-audit-engine"]),
    # /choice-cartograph and /diaboli are single-agent dispatchers.
    ("choice-cartograph", ["choice-cartographer"], []),
    ("diaboli", ["advocatus-diaboli"], []),
]


_PLUGIN_PATH = (
    Path(__file__).resolve().parent.parent.parent / "ai-literacy-superpowers"
)


def _command_body(command_name: str) -> str:
    """Read the body of an orchestration command for matching."""
    component = plugin_runner.find_component(
        _PLUGIN_PATH, name=command_name, component_type="command"
    )
    return plugin_runner.read_component_body(component.path)


def _agent_dispatch_present(body: str, agent_name: str) -> bool:
    """Whether the body contains a dispatch for ``agent_name``.

    Accepts both backticked and un-backticked forms, both
    ``Dispatch the X agent`` and ``Run the X agent`` shapes. The
    matching is deliberately lenient on the verb (the project uses
    several) but strict on the named-agent + " agent" structure.
    """
    backticked = re.compile(
        rf"`{re.escape(agent_name)}`\s+agents?\b(?!-)"
    )
    plain = re.compile(
        rf"\b{re.escape(agent_name)}\s+agents?\b(?!-)"
    )
    return bool(backticked.search(body) or plain.search(body))


def _skill_dispatch_present(body: str, skill_name: str) -> bool:
    """Whether the body contains a load-bearing reference to a skill.

    The reference can be backticked + " skill" or path-style
    ``skills/<name>``. Both forms appear in current commands; both
    count as the command exercising the skill.
    """
    backticked = re.compile(
        rf"`{re.escape(skill_name)}`\s+skills?\b(?!-)"
    )
    path_style = re.compile(
        rf"\bskills/{re.escape(skill_name)}\b"
    )
    return bool(backticked.search(body) or path_style.search(body))


@pytest.mark.structural
class TestOrchestrationDispatchMatrix:
    """Each orchestration command must dispatch the specific agents/skills it
    declares as load-bearing."""

    @pytest.mark.parametrize(
        "command_name,expected_agents,expected_skills",
        DISPATCH_MATRIX,
        ids=lambda v: v if isinstance(v, str) else "",
    )
    def test_command_dispatches_expected_components(
        self,
        command_name: str,
        expected_agents: list[str],
        expected_skills: list[str],
    ):
        body = _command_body(command_name)

        missing_agents = [
            agent
            for agent in expected_agents
            if not _agent_dispatch_present(body, agent)
        ]
        missing_skills = [
            skill
            for skill in expected_skills
            if not _skill_dispatch_present(body, skill)
        ]

        if missing_agents or missing_skills:
            details: list[str] = []
            if missing_agents:
                details.append(
                    f"missing agent dispatches: {missing_agents}"
                )
            if missing_skills:
                details.append(
                    f"missing skill invocations: {missing_skills}"
                )
            pytest.fail(
                f"Command /{command_name} no longer dispatches "
                f"components it is expected to. {'; '.join(details)}.\n"
                "Either the dispatch line was removed in a refactor "
                "and not replaced (a regression), or the matrix in "
                "this test file is out of date and should be updated "
                "alongside the prose change."
            )


@pytest.mark.structural
class TestMatrixCoverage:
    """The matrix itself must be coherent — agents and skills it
    references must exist, every named command must exist, and the
    matrix should cover every orchestration command except the
    deliberate exclusions documented inline."""

    def test_every_referenced_agent_exists(self):
        agent_names = {
            c.name for c in plugin_runner.list_agents(_PLUGIN_PATH)
        }
        broken = []
        for cmd, agents, _ in DISPATCH_MATRIX:
            for agent in agents:
                if agent not in agent_names:
                    broken.append(
                        f"{cmd} expects nonexistent agent {agent!r}"
                    )
        assert not broken, "Matrix references missing agents: " + str(broken)

    def test_every_referenced_skill_exists(self):
        skill_names = {
            c.name for c in plugin_runner.list_skills(_PLUGIN_PATH)
        }
        broken = []
        for cmd, _, skills in DISPATCH_MATRIX:
            for skill in skills:
                if skill not in skill_names:
                    broken.append(
                        f"{cmd} expects nonexistent skill {skill!r}"
                    )
        assert not broken, "Matrix references missing skills: " + str(broken)

    def test_every_named_command_exists(self):
        command_names = {
            c.name for c in plugin_runner.list_commands(_PLUGIN_PATH)
        }
        missing = [
            cmd for cmd, _, _ in DISPATCH_MATRIX if cmd not in command_names
        ]
        assert not missing, (
            f"Matrix names commands that no longer exist: {missing}"
        )
