"""
Tests for aws_session__ps1.

Most of these use real boto3/botocore against throwaway config files rather
than mocks: the point is to notice when a dependency update changes how
botocore reports a missing profile, an expired SSO login, and so on.
"""

import time

import pytest

import aws_session__ps1 as ps1

PROFILES = """\
[profile ok]
aws_access_key_id = AKIAEXAMPLE
aws_secret_access_key = secret

[profile empty]
region = eu-west-1

[profile sso]
sso_session = s
sso_account_id = 123456789012
sso_role_name = Admin
region = eu-west-1

[sso-session s]
sso_start_url = https://example.awsapps.com/start
sso_region = eu-west-1
sso_registration_scopes = sso:account:access
"""


@pytest.fixture
def aws_env(tmp_path, monkeypatch):
    """Point botocore at a throwaway config, with no network lookups."""
    config = tmp_path / "config"
    config.write_text(PROFILES)
    monkeypatch.setenv("HOME", str(tmp_path))  # no real SSO token cache
    monkeypatch.setenv("AWS_CONFIG_FILE", str(config))
    monkeypatch.setenv("AWS_SHARED_CREDENTIALS_FILE", str(tmp_path / "none"))
    monkeypatch.setenv("AWS_EC2_METADATA_DISABLED", "true")
    for var in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"):
        monkeypatch.delenv(var, raising=False)


def run_main(monkeypatch, capsys, profile):
    monkeypatch.setenv("AWS_PROFILE", profile)
    ps1.main()
    return capsys.readouterr().out


def test_default_profile_prints_nothing(aws_env, monkeypatch, capsys):
    monkeypatch.delenv("AWS_PROFILE", raising=False)
    ps1.main()
    assert capsys.readouterr().out == ""


def test_valid_profile(aws_env, monkeypatch, capsys):
    out = run_main(monkeypatch, capsys, "ok")
    assert "🌥️" in out
    assert "ok" in out
    assert "‼️" not in out


@pytest.mark.parametrize("profile", ["missing", "empty", "sso"])
def test_unusable_profiles_are_flagged_not_raised(aws_env, monkeypatch, capsys, profile):
    # missing: ProfileNotFound; empty: no credentials; sso: SSOTokenLoadError
    out = run_main(monkeypatch, capsys, profile)
    assert "⛈️" in out
    assert profile in out
    assert "‼️" in out


def test_colour_codes_are_zero_width_for_bash(aws_env, monkeypatch, capsys):
    out = run_main(monkeypatch, capsys, "sso")
    assert "\001\033[91m\002" in out
    assert "\001\033[0m\002" in out


def test_with_timeout_returns_result():
    assert ps1.with_timeout(lambda: 42, 1) == 42


def test_with_timeout_reraises_errors():
    def boom():
        raise ValueError("boom")

    with pytest.raises(ValueError):
        ps1.with_timeout(boom, 1)


def test_with_timeout_gives_up_on_slow_calls():
    with pytest.raises(ps1.ValidationTimeout):
        ps1.with_timeout(lambda: time.sleep(5), 0.1)
