# QuorumTesting
Repo to host script for Global active device cloud quourm automated testing.
Scripts will automate testing features of menu.sh.

The two zip folders, aws_test.zip and azure_test.zip contain the test script and associated bats software and dependencies. After downloading and unzipping a folder:
1. Make sure instance is set up with one LUN and 4 iqn nodes.
2. WinSCP the unzipped folder into the instance that you wish to run tests on. 
3. Give this folder recursive permissions (chmod -R 777 folder_name).
4. Run the script using command
    - AWS: "./aws_test/bats/bin/bats aws_test/aws_menu_test.bats"
    - Azure: "./azure_test/bats/bin/bats azure_test/azure_menu_test.bats"

*Note: The azure_menu_test is modified to have certain tests behave differently than the aws_menu_test script. See comments in the script for details on why things were changed.
