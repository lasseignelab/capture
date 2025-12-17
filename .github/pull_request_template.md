## Summary
<!-- Describe the change -->

## Author Checklist
- [ ] This repository has a Lasseigne Lab ruleset configured.
  See instructions [here](https://github.com/lasseignelab/project-template/blob/main/DEVELOPMENT.md).
- [ ] Only files relevant to this change are included; no temporary, generated,
  or unrelated files are part of this pull request. Use `.gitignore` to prevent
  irrelevant files from accidentally being included.
- [ ] All automated tests have passed.
- [ ] All automated code checks have passed. The "All checks have passed"
  message should show in the GitHub pull request status box above the
  "Merge pull request" button.
- [ ] No merge conflicts exist. Merge conflicts are indicated by the "This
  branch has conflicts that must be resolved" message in the GitHub pull
  request status box above the "Merge pull request" button.
- [ ] The CHANGELOG has been updated with the planned version number.
- [ ] Setup instructions have been provided.
- [ ] Test instructions have been provided.
- [ ] Cleanup instructions have been provided.
- [ ] At least two reviewers have been requested to review this pull request.

## Self/Peer Review Checklist ([Coding Guidelines](https://docs.google.com/document/d/1h1hxQGrqnQqo1pAxrrtX1OtjHddRTqtgsgDFSXOQpzk/edit?usp=sharing))
- Meaningful variable and function names
- File header comments
- Function comments
- In-line comments summarize logical sections of code by concisely explaining
  why, not what the code is doing.  Avoid excessive or redundant commenting.
- Confirm that the automated tests pass.
- Confirm the code performs the intended functionality

## Setup
<!-- How to setup the project before testing the functionality? -->
Get the code for the pull request.
```
cd ~/bin/capture
git checkout main
git pull
git checkout <branch-name>
```

## Test
<!-- How to test the functionality? -->
Run the automated test suite.
```
cd ~/bin/capture
tests/install
tests/run
```
Test manually in scratch:
```
cd $USER_SCRATCH
cap new --owner lasseignelab "$USER-testing"
```
```
cd "$USER-testing"
```
## Cleanup
* Remove the test directory from scratch:
```
cd "$USER_SCRATCH"
rm -rf "$USER-testing"
```
* Delete the test repo from github.
* Reset CAPTURE to the released version.
```
cap update
```
