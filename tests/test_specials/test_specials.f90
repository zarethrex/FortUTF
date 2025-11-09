! --------------------------------------------------------------------------- !
!                                                                             !
!                           SPECIALS UNIT TESTS                               !
!                                                                             !
! --------------------------------------------------------------------------- !

SUBROUTINE TEST_TRIGGER_FAIL
    USE FORTUTF

    INTEGER :: PRIOR_PASSED, PRIOR_TOTAL

    CALL TAG_TEST("TEST_TRIGGER_FAIL")

    PRIOR_PASSED = FUTF_PASSED
    PRIOR_TOTAL = FUTF_TOTAL

    CALL FAIL

    IF(PRIOR_PASSED == FUTF_PASSED .AND. PRIOR_TOTAL == FUTF_TOTAL - 1 .AND. FUTF_EXIT_CODE == 1) THEN
        FUTF_PASSED = FUTF_PASSED + 1
        FUTF_EXIT_CODE = 0
        TEST_RESULTS(SIZE(TEST_RESULTS)) = '.'
    ELSE
        IF(FUTF_TOTAL /= PRIOR_TOTAL + 1) THEN
            FUTF_TOTAL = PRIOR_TOTAL + 1
        END IF
        FUTF_PASSED = PRIOR_PASSED
    END IF
END SUBROUTINE TEST_TRIGGER_FAIL

SUBROUTINE TEST_TRIGGER_SUCCEED
    USE FORTUTF

    INTEGER :: PRIOR_PASSED, PRIOR_TOTAL

    CALL TAG_TEST("TEST_TRIGGER_SUCCEED")

    PRIOR_PASSED = FUTF_PASSED
    PRIOR_TOTAL = FUTF_TOTAL

    CALL SUCCEED

    IF(PRIOR_PASSED /= FUTF_PASSED - 1 .OR. PRIOR_TOTAL /= FUTF_TOTAL - 1 .AND. FUTF_EXIT_CODE == 0) THEN
        IF(FUTF_TOTAL /= PRIOR_TOTAL + 1) THEN
            FUTF_TOTAL = PRIOR_TOTAL + 1
        END IF
        FUTF_PASSED = PRIOR_PASSED
    END IF

END SUBROUTINE TEST_TRIGGER_SUCCEED

