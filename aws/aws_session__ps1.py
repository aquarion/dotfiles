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
import boto3
import botocore.exceptions
import logging


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
    logging.debug("Session is valid")
    return True


def main():
    """  Main function to check the validity of the AWS session.
    This function initializes a boto3 session, checks the profile name,
    """
    boto_session = boto3.Session()
    if boto_session.profile_name == "default":
        return

    red = "\033[91m"
    reset = "\033[0m"

    status = ''

    if not session_valid_p(boto_session):
        status = f"{red}‼️{reset} "
    
    print(f"(🌥️  {boto_session.profile_name}{status})", end='')



if __name__ == "__main__":
    main()
