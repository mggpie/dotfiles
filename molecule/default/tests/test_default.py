"""Testinfra tests for dotfiles role."""


def test_fish_installed(host):
    """Fish shell should be installed."""
    assert host.package("fish-shell").is_installed


def test_fish_config_exists(host):
    """Fish config should be deployed."""
    f = host.file("/root/.config/fish/config.fish")
    assert f.exists
    assert f.is_file


def test_git_config_exists(host):
    """Git config should be deployed."""
    f = host.file("/root/.config/git/gitconfig")
    assert f.exists
    assert f.is_file


def test_sway_config_exists(host):
    """Sway config should be deployed."""
    f = host.file("/root/.config/sway/config")
    assert f.exists
    assert f.is_file


def test_foot_config_exists(host):
    """Foot terminal config should be deployed."""
    f = host.file("/root/.config/foot/foot.ini")
    assert f.exists
    assert f.is_file


def test_micro_config_exists(host):
    """Micro editor config should be deployed."""
    f = host.file("/root/.config/micro/settings.json")
    assert f.exists
    assert f.is_file


def test_waybar_installed(host):
    """Waybar should be installed."""
    pkg = host.package("waybar")
    assert pkg.is_installed


def test_pipewire_installed(host):
    """PipeWire should be installed."""
    pkg = host.package("pipewire")
    assert pkg.is_installed


def test_para_directories(host):
    """PARA workspace directories should exist."""
    for d in ["0-Inbox", "1-Projects", "2-Areas", "3-Resources", "4-Archives"]:
        assert host.file(f"/root/Desktop/{d}").is_directory


def test_doas_config(host):
    """doas should be configured."""
    f = host.file("/etc/doas.conf")
    assert f.exists


def test_locale_configured(host):
    """Locale should be set."""
    f = host.file("/etc/default/libc-locales")
    assert f.exists
