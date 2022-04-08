setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	# get the containing directory of this file
    	# use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    	# as those will point to the bats executable's location or the preprocessed file respectively
    	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	# make executiables in QuroumTesting/test/scripts/ visible to PATH
	PATH="$DIR/..:$PATH"
}

#teardown() {
	# runs after each test, exit menu.sh so each new test can run menu.sh
#	exit 0
#}	


#Initial setup should have 4 iqns, and 1 Lun
init() {
	printf "1\n1\n1\n1\n1\n1\n2\n4\n2\n3\n2\n2\n2\n1\n9" | ./menu.sh
}

@test "Initialize" {
	run init
	assert_output --partial 'Deleted storage object volume1'
}


menu() {
	printf "9" | ./menu.sh
}

@test "16 Test menu: Run menu.sh" {
	run menu 
	assert_output --partial 'Global-Active Device Cloud Quorum Menu'
}



menu_invalid_int() {
	printf "10\n9" | ./menu.sh
}

@test "17 Test menu: Run menu.sh- invalid integer" {
	run menu_invalid_int
	assert_output --partial 'error: Invalid input please enter an integer within range(1-9)'
}



menu_invalid_int_2() {
	printf "0\n9" | ./menu.sh
}

@test "18 Test menu: Run menu.sh- invalid integer -" {
	run menu_invalid_int_2
	assert_output --partial 'error: Invalid input please enter an integer within range(1-9)'
}



menu_semi_valid_int() {
    printf "01\n9" | ./menu.sh
}

@test "19 Test menu: Run menu.sh- invalid integer 2" {
	run menu_semi_valid_int
	assert_output --partial 'Created LUN'
}



menu_float() {
    printf "2.0\n9" | ./menu.sh
}

@test "20 Test menu: Run menu.sh- input noninteger: float" {
	run menu_float
	assert_output --partial 'error: Invalid input please enter an integer within range(1-9)'
}



menu_letter() {
    printf "a\n9" | ./menu.sh
}

@test "21 Test menu: Run menu.sh- input noninteger: letter" {
	run menu_letter
	assert_output --partial 'error: Invalid input please enter an integer within range(1-9)'
}



menu_blank() {
    printf "\n9" | ./menu.sh
}

@test "22 Test menu: Run menu.sh- input noninteger: do not input anything" {
	run menu_blank
	assert_output --partial 'error: Invalid input please enter an integer within range(1-9)'
}



option1() {
    printf "1\n9" | ./menu.sh
}

@test "23 Test menu: Option 1" {
	run option1
	assert_output --partial 'Created LUN'
}



run_menu1_multiple() {
	# input 1 to menu.sh 6 times
	printf "1\n1\n1\n1\n1\n1\n9" | ./menu.sh
}

@test "24 Test menu:  Option 1 No more free space" {
	run run_menu1_multiple
	assert_output --partial 'error: You have reached max number of quorums to add'
}



delete_quorum_4() {
	# delete quorum 4
	printf "2\n4\n9" | ./menu.sh
}

@test "25 Test menu:  Option 2" {
	run delete_quorum_4
	assert_output --partial 'Deleted storage object volume4'
}



delete_all_quorum() {
	# delete all quorums, only 0, 1, 2, 3 should be left to delete
	printf "2\n3\n2\n2\n2\n1\n2\n0\n2\n9" | ./menu.sh
}

@test "26 Test menu: delete all quorums" {
	run delete_all_quorum
	assert_output --partial 'No quorums available to delete'
}



option2_invalid_int() {
	# input a integer that isn't an option to delete
	printf "1\n2\n8\n0\n1\n9" | ./menu.sh
}

@test "27 Test menu: Option 2 input invalid integer" {
	run option2_invalid_int
	assert_output --partial 'Invalid input please enter an existing quorum'
}



option2_invalid_char() {
	# input a character instead of an int
	printf "2\na\n0\n9" | ./menu.sh
}

@test "28 Test menu: Option 2 input invalid character" {
	run option2_invalid_char
	assert_output --partial 'Invalid input please enter an existing quorum'
}



option2_after_delete(){
	printf "2\n9" | ./menu.sh
}

@test "64 Test menu: Option 2 delete after deleting all quorums using option 2" {
	run option2_after_delete
	assert_output --partial 'error: No quorums available to delete'
}



option1_after_delete(){
    printf "2\n0\n1\n9" | ./menu.sh
}

@test "48 Test menu: option 1 after deleting all quorums using option 2" {
	run option1_after_delete
	assert_output --partial 'Created LUN 0.'
}



option3_enter_iqn() {
	# enter a valid iqn
	printf "3\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f\n9" | ./menu.sh
}

@test "29&30 Test menu: option 3 add a fifth iqn" {
	run option3_enter_iqn
	assert_output --partial 'Created Node ACL for iqn'
}



option3_enter_incorrect_format() {
	# enter an invalid iqn
	printf "3\niq.1994-04.jp.co.hitachi:rsd.r90.i.089c42.1g\n9" | ./menu.sh
}

@test "32 Test menu: option 3 invalid iqn" {
	run option3_enter_incorrect_format
	assert_output --partial 'WWN not valid as: iqn, naa, eui'
}



option3_enter_repeat() {
	# enter an iqn that was already added
	printf "3\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f\n3\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f\n9" | ./menu.sh
}

@test "33 Test menu: option 3 repeat iqn" {
	run option3_enter_repeat
	assert_output --partial 'This NodeACL already exists in configFS'
}



option4_enter_iqn() {
	# enter an iqn to delete
	printf "4\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f\n9" | ./menu.sh
}

@test "34 Test menu: option 4" {
	run option4_enter_iqn
	assert_output --partial 'Deleted Node ACL iqn'
}



option4_enter_nonexistent() {
	# enter an iqn to delete that isn't there
	printf "4\niqn.1994-04.jp.co.hitachi:rsd.r90.i.089c4a.2f\n9" | ./menu.sh
}

@test "35 Test menu: option 4 remove nonexistent iqn" {
	run option4_enter_nonexistent
	assert_output --partial 'No such NodeACL in configfs'
}



option5() {
    printf "5\n9" | ./menu.sh
}

@test "36 Test menu: option 5" {
	run option5
	assert_output --partial 'Created network portal'
}



option6_count_parameter_matches_all() {
	# count the number of times "parameter" is in output
	printf "6\nuser\npass\nuser\npass\ny\n9" | ./menu.sh | grep -c Parameter
}

@test "37&38 Test menu: option 6 apply credentials to all" {
	run option6_count_parameter_matches_all
	assert_output 17
}



option6_select_iqn_01() {
	# count number of times parameter is in output
	printf "6\nuser\npass\nuser\npass\nn\n0 1\n9" | ./menu.sh | grep -c Parameter
}

@test "39 Test Menu: option 6 apply credentials to specific iqns: 0 1" {
	run option6_select_iqn_01 
	assert_output 9
}



option7() {
    printf "7\n9" | ./menu.sh
}

@test "42 Test Menu: option 7" {
    run option7
    assert_output --partial 'backstores'
}



option8() {
    printf "8\n9" | ./menu.sh
}

@test "43 Test Menu: option 8" {
    run option8
    assert_output --partial 'Options:'
}



option9() {
	printf "9" | ./menu.sh
}

@test "44 Test menu: option 9 exit menu" {
	run option9
	assert_success
}



























