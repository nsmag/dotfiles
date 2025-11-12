---
description: Review pull request from the current branch
agent: review
subtask: false
---

Review pull request from the current branch.

First, check the git remote.

If there's no Azure DevOps (dev.azure.com) remote, abort.

Use bash command `az` to check the pull request using these steps:

1. Check the tracking branch of the current branch on the Azure DevOps remote, remember the branch.
2. Run `az repos pr list --detect -s [branch-from-step-1]` to check if the pull request exists.
3. Use the command output from step 2 for further instruction.

If there's any error from `az` command, abort and explain the error.

If there're more than one pull request, display a list in human-readable way and ask for the pull request id before proceeding.

On the remote, use `sourceRefName` as the source branch and `targetRefName` as the target branch.

If there's no pull request, use the current branch as the source branch and the remote main branch as the target branch.

Review code on the source branch compared to the target branch.
Use title and description of the pull request (if any) as addition context.
