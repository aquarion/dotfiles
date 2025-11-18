function aws-am-i-logged-in {
	PROFILE=${1:-$AWS_PROFILE}
	aws --profile="$PROFILE" sts get-caller-identity &>/dev/null
	return $?
}

function aws-login {
	PROFILE=${1:-$AWS_PROFILE}
	if aws-am-i-logged-in "$PROFILE"; then
		echo "[AWS-Login] Already logged in to AWS profile '$PROFILE'"
		return 0
	else
		echo "[AWS-Login] Logging in to AWS profile '$PROFILE'..."
		aws sso login --profile "$PROFILE"
		if aws-am-i-logged-in "$PROFILE"; then
			echo "[AWS-Login] Successfully logged in to AWS profile '$PROFILE'"
			return 0
		else
			echo "[AWS-Login] Failed to log in to AWS profile '$PROFILE'"
			return 1
		fi
	fi
}
