"""
This module provides utilities for working with AWS boto3 sessions, including
validating session credentials and retrieving the profile name.

Functions:
  session_valid_p(boto_session):
    Checks if the provided boto3 session has valid credentials.
    Args:
      boto_session (boto3.Session): The boto3 session to validate.
    Returns:
      bool: True if the session credentials are valid, False otherwise.

  profile_name(boto_session):
    Retrieves the profile name associated with the provided boto3 session.
    Args:
      boto_session (boto3.Session): The boto3 session to query.
    Returns:
      str: The profile name of the session.

  main():
    Main function that initializes a boto3 session, checks the profile name,
    and prints a message indicating whether the session credentials are valid.
    If the profile name is "default", the function exits without further action.
"""

import logging
import threading
import time

import boto3
import botocore.exceptions


class TimeoutError(Exception):
    """Custom timeout exception."""
    pass


def with_timeout(func, timeout_duration):
    """
    Execute a function with a timeout.
    
    Args:
        func: The function to execute
        timeout_duration: Timeout in seconds (can be fractional)
    
    Returns:
        The function result if successful, raises TimeoutError if timeout occurs
    """
    result = [None]
    exception = [None]
    
    def target():
        try:
            result[0] = func()
        except Exception as e:
            exception[0] = e
    
    thread = threading.Thread(target=target)
    thread.daemon = True
    thread.start()
    thread.join(timeout_duration)
    
    if thread.is_alive():
        raise TimeoutError("Operation timed out")
    
    if exception[0]:
        raise exception[0]
    
    return result[0]


def session_valid_p(boto_session):
    """
    Checks if the given boto3 session is valid.

    This function verifies the validity of a boto3 session by checking
    if the session's credentials require a refresh. If the credentials
    need to be refreshed, the session is considered invalid.

    Args:
      boto_session (boto3.Session): The boto3 session to validate.

    Returns:
      bool: True if the session is valid, False otherwise.
    """
    def check_credentials():
        credentials = boto_session.get_credentials()
        # if credentials.refresh_needed():
        #     logging.debug("Session needs refresh")
        #     return False
        try:
            credentials.get_frozen_credentials()
            # logging.debug("Session expires at %s", expires)
        except botocore.exceptions.TokenRetrievalError:
            logging.debug("Token retrieval error")
            return False
        except RuntimeError:
            logging.debug("Runtime error while retrieving credentials")
            return False
        logging.debug("Session is valid")
        return True
    
    try:
        return with_timeout(check_credentials, 0.5)  # 0.5 second timeout
    except TimeoutError:
        logging.debug("Session validation timed out")
        return False


def main():
    """Main function to check the validity of the AWS session.
    This function initializes a boto3 session, checks the profile name,
    """
    boto_session = boto3.Session()
    if boto_session.profile_name == "default":
        return

    red = "\033[91m"
    reset = "\033[0m"

    status = ""

    if not session_valid_p(boto_session):
        status = f"{red}‼️{reset} "
        cloud = "⛈️"
    else    :
        cloud = "🌥️"
    print(f"[{cloud}  {boto_session.profile_name}{status}]", end="")


if __name__ == "__main__":
    main()
