"""Testinfra tests for dotfiles role.

Focus on contracts and behaviour, not file existence (Ansible guarantees that).
Tests cover what molecule actually converges — hardware/GUI/runit tags are skipped.
"""


# ---------- Security: doas permissions ----------


def test_doas_permissions(host):
    """doas.conf must be 0400 — writable doas.conf = privilege escalation."""
    f = host.file("/etc/doas.conf")
    assert f.exists
    assert oct(f.mode) == "0o400"


def test_doas_grants_wheel_nopass(host):
    """doas must grant nopass to wheel group."""
    f = host.file("/etc/doas.conf")
    assert "permit nopass :wheel" in f.content_string


# ---------- Base packages ----------


def test_base_packages_installed(host):
    """Core packages must be installed."""
    for pkg in ["chrony", "cronie", "elogind", "dbus"]:
        assert host.package(pkg).is_installed, f"Missing package: {pkg}"


def test_nonfree_repo_enabled(host):
    """Nonfree repository must be installed."""
    assert host.package("void-repo-nonfree").is_installed


# ---------- XDG & PARA directories ----------


def test_xdg_directories(host):
    """Standard XDG user directories must exist."""
    for d in ["Desktop", "Downloads", "Documents", "Music", "Pictures", "Videos"]:
        assert host.file(f"/root/{d}").is_directory


def test_para_directories(host):
    """PARA workspace directories must exist with correct names."""
    for d in ["0-Inbox", "1-Projects", "2-Areas", "3-Resources", "4-Archives"]:
        assert host.file(f"/root/Desktop/{d}").is_directory


# ---------- Fish: config deployed ----------


def test_fish_installed(host):
    """Fish shell must be installed."""
    assert host.package("fish").is_installed


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


# ---------- Git config ----------


def test_git_installed(host):
    """Git must be installed."""
    assert host.package("git").is_installed


def test_git_config_deployed(host):
    """Git config must be deployed."""
    f = host.file("/root/.config/git/config")
    assert f.exists


# ---------- CLI tools: config deployed ----------


def test_htop_config(host):
    """htop config must be deployed."""
    assert host.file("/root/.config/htop/htoprc").exists


def test_micro_config(host):
    """micro settings must be deployed."""
    assert host.file("/root/.config/micro/settings.json").exists


def test_neovim_config(host):
    """Neovim init.lua must be deployed."""
    assert host.file("/root/.config/nvim/init.lua").exists


def test_lf_config(host):
    """lf file manager config must be deployed."""
    assert host.file("/root/.config/lf/lfrc").exists


def test_fastfetch_config(host):
    """fastfetch config must be deployed."""
    assert host.file("/root/.config/fastfetch/config.jsonc").exists


# ---------- Crontab ----------


def test_crontab_has_move_downloads(host):
    """move-downloads must be in crontab for PARA inbox flow."""
    cron = host.run("crontab -l")
    assert "move-downloads" in cron.stdout

