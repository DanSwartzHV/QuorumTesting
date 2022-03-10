setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	# get the containing directory of this file
    	# use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    	# as those will point to the bats executable's location or the preprocessed file respectively
    	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	# make executiables in QuroumTesting/test/scripts/ visible to PATH
	#PATH="$DIR/..:$PATH"
}

#teardown() {
	# runs after each test, exit menu.sh so each new test can run menu.sh
#	exit 0
#}	


#Initial setup should have 4 iqns, and 1 Lun
init() {
	printf "1/n1/n1/n1/n1/n2/n3/n2/n2/n2/n1/n9" | ./menu.sh
}

@test "Initialize" {
	run init
	assert_success
}



@test "16 Test menu: Run menu.sh" {
	run menu.sh
	assert_success
}



@test "17 Test menu: Run menu.sh- invalid integer" {
	run menu.sh 10
	assert_output --partial 'error: Invalid input please enter an integer within range (1-9)'
}



@test "18 Test menu: Run menu.sh- invalid integer -" {
	run menu.sh 0
	assert_output --partial 'error: Invalid input please enter an integer within range (1-9)'
}



@test "19 Test menu: Run menu.sh- invalid integer 2" {
	run menu.sh 01
	assert_output --partial 'Created LUN'
}



@test "20 Test menu: Run menu.sh- input noninteger: float" {
	run menu.sh 2.0
	assert_output --partial 'error: Invalid input please enter an integer within range (1-9)'
}



@test "21 Test menu: Run menu.sh- input noninteger: letter" {
	run menu.sh a
	assert_output --partial 'error: Invalid input please enter an integer within range (1-9)'
}



@test "22 Test menu: Run menu.sh- input noninteger: do not input anything" {
	run menu.sh ""
	assert_output --partial 'error: Invalid input please enter an integer within range (1-9)'
}



@test "23 Test menu: Option 1" {
	run menu.sh 1
	assert_output --partial 'Created LUN'
}



run_menu1_multiple() {
	# input 1 to menu.sh 5 times
	printf "1\n1\n1\n1\n1" | ./menu.sh
}



@test "24 Test menu:  Option 1 No more free space" {
	run run_menu1_multiple
	assert_output --partial 'Could not expand file'
}



delete_quorum_3() {
	# delete quorum 3
	printf "2\n3" | ./menu.sh
}

@test "25 Test menu:  Option 2" {
	run delete_quorum_3
	assert_output --partial 'Deleted storage object volume3'
}



delete_all_quorum() {
	# delete all quorums, only 0, 1, 2 should be left
	printf "2\n2\n2\n1\n2\n0 | ./menu.sh
}

@test "26 Test menu: delete all quorums" {
	run delete_all_quorum
	assert_output --partial 'Deleted storage object volume0'
}



option2_invalid_int() {
	# input a integer that isn't an option to delete
	printf "2\n9" | ./menu.sh
}

@test "27 Test menu: Option 2 input invalid integer" {
	run option2_invalid_int
	assert_output --partial 'Invalid input please enter an existing quorum'
}



option2_invaid_char() {
	# input a character instead of an int
	printf "2\na" | ./menu.sh
}

@test "28 Test menu: Option 2 input invalid character" {
	run option2_invalid_char
	assert_output --partial 'Invalid input please enter an existing quorum'
}



@test "48 Test menu: option 1 after deleting all quorums using option 2" {
	run menu.sh 1
	assert_output --partial 'Created Lun 0.'
}



option3_enter_iqn() {
	# enter a valid iqn
	printf "3\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f" | ./menu.sh
}

@test "29&30 Test menu: option 3 add a fifth iqn" {
	run option3_ente_iqn
	assert_output --partial 'Created Node ACL for iqn'
}



option3_enter_incorrect_format() {
	# enter an invalid iqn
	printf "3\niq.1994-04.jp.co.hitachi:rsd.r90.i.089c42.1g" | ./menu.sh
}

@test "32 Test menu: option 3 invalid iqn" {
	run option3_enter_incorrect_format
	assert_output --partial 'WWN nt valid as: iqn, naa,eui'
}



option3_enter_repeat() {
	# enter an iqn that was already added
	printf "3\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f" | ./menu.sh
}

@test "33 Test menu: option 3 repeat iqn" {
	run option3_enter_repeat
	assert_output --partial 'This NodeACL already exists in configFS'
}



option4_enter_iqn() {
	# enter an iqn to delete
	printf "4\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f" | ./menu.sh
}

@test "34 Test menu: option 4" {
	run option4_enter_iqn
	assert_output --partial 'Deleted Node ACL iqn'
}



option4_enter_nonexistent() {
	# enter an iqn to delete that isn't there
	printf "4\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f" | ./menu.sh
}

@test "35 Test menu: option 4 remove nonexistent iqn"
	run option4_enter_nonexistent
	assert_output --partial 'No such NodeACL in configs'
}



@test "36 Test menu: option 5" {
	run menu.sh 5
	assert_output --partial 'Created network portal'
}



option6_count_parameter_matches_all() {
	# count the number of times "parameter" is in output
	printf "6\nuser\npass\nuser\npass\ny" | ./menu.sh | grep -c Parameter
}

@test "37&38 Test menu: option 6 apply credentials to all" {
	run option6_count_parameter_matches_all
	assert_output 16
}



option6_select_iqn_01() {
	# count number of times parameter is in output
	printf "6\nuser\npass\nuser\npass\nn\n0 1" | ./menu.sh | grep -c Parameter
}

@test "39 Test Menu: option 6 apply credentials to specific iqns: 0 1" {
	run option6_select_iqn_01 
	assert_output 8
}



option6_apply_no_iqn() {
	# need to remove all iqns, return this output, then re-add iqns
	# know that trying to run 6 with no iqn's returns "no existing array connections"
	# so there is no need to test further
}

@test "40 Test menu: option 6 apply to all without iqns added" {
	skip "Unsure how to implement this test"
}



@test "41 Test menu: option 6 apply to specific iqns without any iqns added
	skip "know that if there are no iqns available, 6 will immediately return no existing connections"
}



@test "44 Test menu: option 9 exit menu" {
	run menu.sh 9
	assert_success
}



























