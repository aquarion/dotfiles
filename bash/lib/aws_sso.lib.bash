function aws-am-i-logged-in {
	local PROFILE=${1:-$AWS_PROFILE}
	aws --profile="$PROFILE" sts get-caller-identity &>/dev/null
	return $?
}

function aws-login {
	local PROFILE=${1:-$AWS_PROFILE}
	# Chatter goes to stderr, so test stderr for a terminal. Testing stdin (-t 0)
	# is wrong: `X=$(...)` only redirects stdout, leaving stdin a tty.
	local IS_INTERACTIVE=0
	[[ -t 2 ]] && IS_INTERACTIVE=1
	[ "$IS_INTERACTIVE" -eq 1 ] && echo "[AWS-Login] Checking if already logged in to AWS profile '$PROFILE'..." >&2
	if aws-am-i-logged-in "$PROFILE"; then
		[ "$IS_INTERACTIVE" -eq 1 ] && echo "[AWS-Login] Already logged in to AWS profile '$PROFILE'" >&2
		return 0
	else
		[ "$IS_INTERACTIVE" -eq 1 ] && echo "[AWS-Login] Logging in to AWS profile '$PROFILE'..." >&2
		aws sso login --profile "$PROFILE"
		if aws-am-i-logged-in "$PROFILE"; then
			[ "$IS_INTERACTIVE" -eq 1 ] && echo "[AWS-Login] Successfully logged in to AWS profile '$PROFILE'" >&2
			return 0
		else
			[ "$IS_INTERACTIVE" -eq 1 ] && echo "[AWS-Login] Failed to log in to AWS profile '$PROFILE'" >&2
			return 1
		fi
	fi
	# Set global AWS_PROFILE to the profile used for login
	AWS_PROFILE="$PROFILE"
}
