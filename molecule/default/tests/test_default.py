"""Testinfra tests for dotfiles role.

Focus on contracts and behaviour, not file existence (Ansible guarantees that).
Tests cover: permissions, content correctness, service state, shell config.
"""


# ---------- Security: file permissions ----------


def test_ssh_dir_permissions(host):
    """~/.ssh must be 0700 — anything else leaks keys."""
    d = host.file("/root/.ssh")
    assert d.exists
    assert d.is_directory
    assert oct(d.mode) == "0o700"


def test_ssh_config_permissions(host):
    """SSH config must be 0600."""
    f = host.file("/root/.ssh/config")
    assert f.exists
    assert oct(f.mode) == "0o600"


def test_doas_permissions(host):
    """doas.conf must be 0400 — writable doas.conf = privilege escalation."""
    f = host.file("/etc/doas.conf")
    assert f.exists
    assert oct(f.mode) == "0o400"


def test_doas_grants_wheel_nopass(host):
    """doas must grant nopass to wheel group."""
    f = host.file("/etc/doas.conf")
    assert "permit nopass :wheel" in f.content_string


# ---------- Shell: fish is default, env is rendered ----------


def test_fish_is_default_shell(host):
    """Fish must be set as default shell, not just installed."""
    passwd = host.file("/etc/passwd")
    assert "/bin/fish" in passwd.content_string


def test_fish_env_rendered(host):
    """env.fish must have bose_mac rendered (not raw Jinja2)."""
    f = host.file("/root/.config/fish/conf.d/env.fish")
    assert f.exists
    # Template must be rendered — no raw {{ }} should remain
    assert "{{ bose_mac }}" not in f.content_string
    assert "BOSE_QC45_MAC" in f.content_string


def test_fish_functions_deployed(host):
    """Core fish functions must exist."""
    for fn in ["deploy", "tv", "bose", "radio", "upall"]:
        f = host.file(f"/root/.config/fish/functions/{fn}.fish")
        assert f.exists, f"Missing fish function: {fn}.fish"


# ---------- Shortcuts: must be executable ----------


def test_shortcuts_are_executable(host):
    """Every file in ~/.local/bin must be +x."""
    result = host.run("find /root/.local/bin -type f ! -executable")
    assert result.stdout.strip() == "", (
        f"Non-executable shortcuts found:\n{result.stdout}"
    )


# ---------- System services ----------


def test_runit_services_enabled(host):
    """Core runit services must be symlinked to /var/service/."""
    for svc in ["chronyd", "dbus", "cronie"]:
        link = host.file(f"/var/service/{svc}")
        assert link.exists, f"Service {svc} not enabled"
        assert link.is_symlink


def test_tty3_to_6_disabled(host):
    """TTY 3-6 should be disabled (only TTY1-2 kept)."""
    for tty in [3, 4, 5, 6]:
        link = host.file(f"/var/service/agetty-tty{tty}")
        assert not link.exists, f"TTY{tty} should be disabled"


def test_elogind_power_button_ignored(host):
    """Power button must be handled by sway, not elogind."""
    f = host.file("/etc/elogind/logind.conf")
    assert "HandlePowerKey=ignore" in f.content_string


# ---------- Nix ----------


def test_nix_experimental_features(host):
    """Nix must have flakes and nix-command enabled."""
    f = host.file("/root/.config/nix/nix.conf")
    assert f.exists
    content = f.content_string
    assert "nix-command" in content
    assert "flakes" in content


# ---------- Config content correctness ----------


def test_sway_config_has_performance_tuning(host):
    """Sway config must include max_render_time for smooth rendering."""
    f = host.file("/root/.config/sway/config")
    assert "max_render_time" in f.content_string


def test_wireplumber_bluetooth_config(host):
    """WirePlumber must have Bluetooth AAC codec config."""
    f = host.file(
        "/root/.config/wireplumber/wireplumber.conf.d/50-bluez-config.conf"
    )
    assert f.exists
    content = f.content_string
    assert "bluez5.codecs" in content
    assert "aac" in content


def test_para_directories(host):
    """PARA workspace directories must exist with correct names."""
    for d in ["0-Inbox", "1-Projects", "2-Areas", "3-Resources", "4-Archives"]:
        assert host.file(f"/root/Desktop/{d}").is_directory


def test_crontab_has_upall_check(host):
    """upall-check must be in crontab for weekly maintenance."""
    cron = host.run("crontab -l")
    assert "upall-check" in cron.stdout


def test_crontab_has_move_downloads(host):
    """move-downloads must be in crontab for PARA inbox flow."""
    cron = host.run("crontab -l")
    assert "move-downloads" in cron.stdout

