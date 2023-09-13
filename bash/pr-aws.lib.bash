
lsaws() {
    profile=$1
    shift;
    search=$1

    echo "Profile: '${profile}' Search: '${search}'"

    aws --profile="${profile}" ec2 describe-instances | jq -r -f ~/code/IDL/idl-scripts/aws-instances.jq --arg search "${search}" | sort | column -t -s' '
}

lsawsid() {
    profile=$1
    shift;
    search=$1

    echo "Profile: '${profile}' Search: '${search}'"

    aws --profile="${profile}" ec2 describe-instances | jq -r -f ~/code/IDL/idl-scripts/aws-instances-instanceid.jq --arg search "${search}" | sort | column -t -s' '
}

# alias idlprod='ssh -l ubuntu -i ~/.ssh/web-prod.pem'
# alias idlstage='ssh -l ubuntu -i ~/.ssh/web-stage.pem'

# alias tacazure='ssh -i ~/.ssh/linux-azure.key -l tacadmin'
# alias tacprod='ssh -i ~/.ssh/tac-prod.pem -l ubuntu'
# alias tacstage='ssh -i ~/.ssh/tac-stage.pem -l ubuntu'

# alias cblprod='ssh -l ubuntu -i ~/.ssh/cbl-web-prod.pem'
# alias cblstage='ssh -l ubuntu -i ~/.ssh/cbl-web-stage.pem'

function idlprod {
	ssh -l ubuntu -i ~/.ssh/pr-aws/web-prod.pem "${@:1}"
 }
function idlstage {
	ssh -l ubuntu -i ~/.ssh/pr-aws/web-stage.pem "${@:1}"
 }

function tacazure {
	ssh -i ~/.ssh/pr-aws/linux-azure.key -l tacadmin "${@:1}"
 }
function tacprod {
	ssh -i ~/.ssh/pr-aws/tac-prod.pem -l ubuntu "${@:1}"
 }
function tacstage {
	ssh -i ~/.ssh/pr-aws/tac-stage.pem -l ubuntu "${@:1}"
 }

function cblprod {
	ssh -l ubuntu -i ~/.ssh/pr-aws/cbl-web-prod.pem "${@:1}"
 }
function cblstage {
	ssh -l ubuntu -i ~/.ssh/pr-aws/cbl-web-stage.pem "${@:1}"
 }

function sshgcms {
	ssh -l ubuntu -i ~/.ssh/pr-aws/globalcms-devops.pem "${@:1}"
}

