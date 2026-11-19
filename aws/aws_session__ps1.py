"""
Prints a short AWS status for use in a bash prompt: the current profile name,
with a warning marker if its credentials can't be retrieved (for example an
expired SSO login). Prints nothing for the "default" profile.
"""

import logging
import os
import threading

import boto3
import botocore.exceptions


class ValidationTimeout(Exception):
    """Raised when a call takes longer than its allowed time."""


def with_timeout(func, timeout_duration):
    """
    Execute a function with a timeout.

    Args:
        func: The function to execute
        timeout_duration: Timeout in seconds (can be fractional)

    Returns:
        The function result if successful, raises ValidationTimeout if timeout occurs
    """
    result = [None]
    exception = [None]

    def target():
        try:
            result[0] = func()
        except Exception as e:
            exception[0] = e

    # Daemon thread so a hung credential lookup can't block interpreter exit.
    thread = threading.Thread(target=target, daemon=True)
    thread.start()
    thread.join(timeout_duration)

    if thread.is_alive():
        raise ValidationTimeout("Operation timed out")

    if exception[0]:
        raise exception[0]

    return result[0]


def session_valid_p(boto_session):
    """
    Checks if the given boto3 session can retrieve credentials.

    Any botocore error (expired SSO token, missing credentials, ...) or a
    timeout counts as invalid. A slow network can therefore give a false
    "invalid", which is acceptable for a prompt hint.

    Args:
      boto_session (boto3.Session): The boto3 session to validate.

    Returns:
      bool: True if the session is valid, False otherwise.
    """

    def check_credentials():
        credentials = boto_session.get_credentials()
        if credentials is None:
            logging.debug("No credentials found")
            return False
        try:
            credentials.get_frozen_credentials()
        except (botocore.exceptions.BotoCoreError, RuntimeError) as e:
            logging.debug("Could not retrieve credentials: %s", e)
            return False
        logging.debug("Session is valid")
        return True

    try:
        return with_timeout(check_credentials, 0.5)
    except ValidationTimeout:
        logging.debug("Session validation timed out")
        return False
    except botocore.exceptions.BotoCoreError as e:
        logging.debug("Session validation failed: %s", e)
        return False


def main():
    """Print the profile name, flagged if the session is not valid."""
    # \001 and \002 mark the colour codes as zero-width so bash doesn't count
    # them when working out the prompt length.
    red = "\001\033[91m\002"
    reset = "\001\033[0m\002"

    try:
        boto_session = boto3.Session()
        profile = boto_session.profile_name
        valid = profile == "default" or session_valid_p(boto_session)
    except botocore.exceptions.BotoCoreError as e:
        # e.g. AWS_PROFILE names a profile that isn't in the config
        logging.debug("Could not create session: %s", e)
        profile = os.environ.get("AWS_PROFILE", "unknown")
        valid = False

    if profile == "default":
        return

    if valid:
        cloud, status = "🌥️", ""
    else:
        cloud, status = "⛈️", f"{red}‼️{reset} "
    print(f"[{cloud}  {profile}{status}]", end="")


if __name__ == "__main__":
    main()
