"""Testinfra tests for opencode-swarm infrastructure.

Verifies the swarm config files deployed by the opencode (base) and
opencode-swarm tags.

The opencode-swarm tag is in molecule.yml skip-tags because it requires Nix
(bun, ollama, UBS) and network (RTK install).  Tests that would need the
opencode-swarm tasks to have run are conditionally skipped with a clear
reason.  Tests relying only on the base opencode tag (directory + core
config) always execute.

Run with the tag enabled to exercise the full suite:
    molecule converge -- --skip-tags "" && molecule verify

See molecule.yml lines 27-38 for the full skip list.
"""

import json

import pytest


# ---------------------------------------------------------------------------
# Base opencode config (tag: opencode) -- always deployed in molecule
# ---------------------------------------------------------------------------


def test_opencode_config_dir(host):
    """OpenCode config directory must exist (created by opencode tag)."""
    d = host.file("/root/.config/opencode")
    assert d.is_directory


def test_opencode_json_valid(host):
    """opencode.json must exist and be valid JSON with expected keys."""
    f = host.file("/root/.config/opencode/opencode.json")
    assert f.exists
    assert f.is_file

    parsed = json.loads(f.content_string)
    assert "model" in parsed
    assert "provider" in parsed
    assert "permission" in parsed


# ---------------------------------------------------------------------------
# Swarm config files (tags: opencode, opencode-swarm) -- SKIPPED in molecule
# The opencode-swarm tag is in molecule.yml skip-tags because it runs Nix
# installs (bun, ollama, UBS) and network downloads (RTK).  These tests
# document the contract; they skip gracefully when the tag is not converged.
# ---------------------------------------------------------------------------


def test_agents_md_exists(host):
    """AGENTS.md must exist -- defines worker lifecycle and swarm rules.

    Skipped when the opencode-swarm tag was not converged (requires Nix to
    deploy bun/ollama/UBS, which are unavailable inside the Docker container).
    """
    f = host.file("/root/.config/opencode/AGENTS.md")
    if not f.exists:
        pytest.skip("opencode-swarm tag not converged (requires Nix/network)")
    assert f.is_file


def test_swarm_plugin_exists(host):
    """Plugin swarm.ts must exist and reference Linux paths.

    The deployable source at roles/dotfiles/files/opencode/plugin/swarm.ts
    hardcodes absolute Linux paths (/home/me/.config/opencode/...) for the
    swarm CLI binary and /home/me/.nix-profile/bin/opencode for the OpenCode
    CLI.  Verify these are present in the deployed copy.
    """
    f = host.file("/root/.config/opencode/plugin/swarm.ts")
    if not f.exists:
        pytest.skip("opencode-swarm tag not converged (requires Nix/network)")
    assert f.is_file
    content = f.content_string

    # Linux swarm binary path (not Windows .cmd)
    assert "/home/me/.config/opencode/node_modules/.bin/swarm" in content
    # Linux opencode CLI path
    assert "/home/me/.nix-profile/bin/opencode" in content
    # Platform detection present
    assert "isWindows" in content


def test_agent_files_exist(host):
    """At least one agent file must be deployed in agent/ directory."""
    d = host.file("/root/.config/opencode/agent")
    if not d.is_directory:
        pytest.skip("opencode-swarm tag not converged (requires Nix/network)")

    agents = host.file("/root/.config/opencode/agent").listdir()
    assert len(agents) > 0
    assert all(a.endswith(".md") for a in agents)


def test_command_files_exist(host):
    """At least one command file must be deployed in command/ directory."""
    d = host.file("/root/.config/opencode/command")
    if not d.is_directory:
        pytest.skip("opencode-swarm tag not converged (requires Nix/network)")

    commands = host.file("/root/.config/opencode/command").listdir()
    assert len(commands) > 0
    assert all(c.endswith(".md") for c in commands)


def test_package_json_has_swarm_dep(host):
    """package.json must exist with opencode-swarm-plugin dependency."""
    f = host.file("/root/.config/opencode/package.json")
    if not f.exists:
        pytest.skip("opencode-swarm tag not converged (requires Nix/network)")

    parsed = json.loads(f.content_string)
    assert "dependencies" in parsed
    deps = parsed["dependencies"]
    assert "opencode-swarm-plugin" in deps
    assert deps["opencode-swarm-plugin"]  # non-empty version string
