"""Layer 1 structural + wiring tests for the model-cards plugin.

The repo ships two plugins side-by-side under ``marketplace.json``:
ai-literacy-superpowers (large, the primary subject of the existing
TDAD suite) and model-cards (small, focused on Mitchell-style model
card authoring). Both deserve at least Layer 1 coverage — the bar
for a plugin to ship is "every component is structurally sound and
references resolve."

The model-cards plugin is small enough that per-category matrices
(orchestration / model-mediated) would be overkill — it has one
agent, one skill, one command, and that command's wiring is fully
captured by the generic resolver below. If the plugin grows beyond a
single component of each type, this file should evolve toward the
matrix-style coverage the larger plugin uses.

This module mirrors a subset of ``test_layer1_structural.py`` and
``test_command_wiring.py``, scoped to the model-cards plugin path
via the ``model_cards_path`` fixture in conftest.py. The shared
``runner.plugin`` helpers do not bake in any assumption about which
plugin they run against, so re-using them here is mechanical.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402

# Reuse the reference-extraction patterns from the existing wiring
# test rather than duplicating regex maintenance — the patterns are
# the same regardless of which plugin's command bodies they run
# against.
from tests.test_command_wiring import extract_references  # noqa: E402


@pytest.mark.structural
class TestModelCardsComponents:
    """Every model-cards component must have well-formed frontmatter."""

    def test_at_least_one_agent_exists(self, model_cards_path: Path):
        agents = list(plugin_runner.list_agents(model_cards_path))
        assert agents, "model-cards plugin has no agents"

    def test_at_least_one_skill_exists(self, model_cards_path: Path):
        skills = list(plugin_runner.list_skills(model_cards_path))
        assert skills, "model-cards plugin has no skills"

    def test_at_least_one_command_exists(self, model_cards_path: Path):
        commands = list(plugin_runner.list_commands(model_cards_path))
        assert commands, "model-cards plugin has no commands"

    def test_every_component_has_a_name(self, model_cards_path: Path):
        components = list(plugin_runner.list_agents(model_cards_path))
        components.extend(plugin_runner.list_skills(model_cards_path))
        components.extend(plugin_runner.list_commands(model_cards_path))
        missing = [
            f"{c.component_type}:{c.name}"
            for c in components
            if not c.frontmatter.get("name")
        ]
        assert not missing, (
            f"Components in model-cards missing 'name' frontmatter: {missing}"
        )

    def test_every_component_has_a_description(
        self, model_cards_path: Path
    ):
        components = list(plugin_runner.list_agents(model_cards_path))
        components.extend(plugin_runner.list_skills(model_cards_path))
        components.extend(plugin_runner.list_commands(model_cards_path))
        missing = [
            f"{c.component_type}:{c.name}"
            for c in components
            if not c.frontmatter.get("description")
        ]
        assert not missing, (
            "Components in model-cards missing 'description' "
            f"frontmatter: {missing}"
        )

    def test_every_skill_has_skill_md(self, model_cards_path: Path):
        broken = [
            c.name
            for c in plugin_runner.list_skills(model_cards_path)
            if not c.path.exists()
        ]
        assert not broken, (
            f"model-cards skills missing SKILL.md: {broken}"
        )


@pytest.mark.structural
class TestModelCardsWiring:
    """Every reference in a model-cards command body must resolve to
    a real component within the model-cards plugin."""

    def test_command_references_resolve(self, model_cards_path: Path):
        commands = list(plugin_runner.list_commands(model_cards_path))
        agent_names = {
            c.name for c in plugin_runner.list_agents(model_cards_path)
        }
        skill_names = {
            c.name for c in plugin_runner.list_skills(model_cards_path)
        }

        broken: list[str] = []
        for command in commands:
            body = plugin_runner.read_component_body(command.path)
            refs = extract_references(body)
            for missing in refs["agent"] - agent_names:
                broken.append(
                    f"model-cards command /{command.name} references "
                    f"missing agent {missing!r}"
                )
            for missing in refs["skill"] - skill_names:
                broken.append(
                    f"model-cards command /{command.name} references "
                    f"missing skill {missing!r}"
                )
        assert not broken, (
            "Broken references in model-cards command bodies:\n  - "
            + "\n  - ".join(broken)
        )


@pytest.mark.structural
class TestModelCardsExpectedComponents:
    """Spot-check that the documented model-cards components are
    actually present. Catches the case where someone deletes a
    canonical component without realising it was load-bearing for
    other documentation or for the marketplace listing."""

    def test_model_card_researcher_agent_present(
        self, model_cards_path: Path
    ):
        component = plugin_runner.find_component(
            model_cards_path,
            name="model-card-researcher",
            component_type="agent",
        )
        description = component.frontmatter.get("description") or ""
        assert "model card" in description.lower(), (
            "model-card-researcher agent description must mention "
            "'model card' for the Claude Code skill matcher to fire"
        )

    def test_model_cards_skill_present(self, model_cards_path: Path):
        plugin_runner.find_component(
            model_cards_path,
            name="model-cards",
            component_type="skill",
        )

    def test_model_card_command_present(
        self, model_cards_path: Path
    ):
        component = plugin_runner.find_component(
            model_cards_path,
            name="model-card",
            component_type="command",
        )
        assert component.frontmatter.get("description"), (
            "model-card command must declare a description"
        )
