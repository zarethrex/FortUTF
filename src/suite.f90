MODULE FUTF_SUITE
    USE FUTF_UTILITIES, ONLY: APPEND_CHAR, APPEND_INT
    IMPLICIT NONE

    PUBLIC
    INTEGER :: FUTF_PASSED    = 0                   ! Number of FUTF_PASSED Tests
    INTEGER :: FUTF_TOTAL     = 0                   ! FUTF_TOTAL Number of Tests
    INTEGER :: FUTF_EXIT_CODE = 0                   ! Test Suite Exit Code
    CHARACTER(LEN=100) :: IDENTIFIER = "UNNAMED TEST"    ! String for Test Labels
    CHARACTER(LEN=100), DIMENSION(:), ALLOCATABLE :: TEST_NAMES
    CHARACTER(LEN=1), DIMENSION(:), ALLOCATABLE :: TEST_RESULTS
    CHARACTER(LEN=300), DIMENSION(:), ALLOCATABLE :: INFO_STRINGS

    CONTAINS

    SUBROUTINE TAG_TEST(TEST_NAME)
        CHARACTER(LEN=*), INTENT(IN) :: TEST_NAME
        IDENTIFIER = TEST_NAME
    END SUBROUTINE

    SUBROUTINE REGISTER_FAILED
        FUTF_TOTAL  = FUTF_TOTAL + 1
        TEST_RESULTS = APPEND_CHAR(TEST_RESULTS, 'F', 1)

        ! If no test name specified use default 'Test #
        IF(IDENTIFIER == "UNNAMED TEST") THEN
            WRITE(IDENTIFIER, '(A, i0)') "TEST ", SIZE(TEST_NAMES) + 1
        END IF

        TEST_NAMES = APPEND_CHAR(TEST_NAMES, IDENTIFIER, LEN(IDENTIFIER))

        IDENTIFIER = "UNNAMED TEST" ! Return to default
        FUTF_EXIT_CODE = 1
    END SUBROUTINE

    SUBROUTINE REGISTER_PASSED
        FUTF_PASSED = FUTF_PASSED + 1
        FUTF_TOTAL  = FUTF_TOTAL + 1
        TEST_RESULTS = APPEND_CHAR(TEST_RESULTS, '.', 1)

        ! If no test name specified use default 'Test #'
        IF(IDENTIFIER == "UNNAMED TEST") THEN
            WRITE(IDENTIFIER, '(A, i0)') "TEST ", SIZE(TEST_NAMES) + 1
        END IF
        TEST_NAMES = APPEND_CHAR(TEST_NAMES, IDENTIFIER, LEN(IDENTIFIER))
        IDENTIFIER = "UNNAMED TEST"
    END SUBROUTINE

    SUBROUTINE FAILED_TEST_SUMMARY

        INTEGER, DIMENSION(:), ALLOCATABLE :: IFAILED
        INTEGER :: NTESTS, N_FAILED, I
        LOGICAL, SAVE :: PRINT_NAMED_FAILED_TESTS = .TRUE.

        NTESTS = SIZE(TEST_NAMES)
        N_FAILED = FUTF_TOTAL-FUTF_PASSED

        ! If the status reset has been called then the exit
        ! code may be set to 0 despite the number of failed
        ! tests being non-zero, this corrects for that
        IF(N_FAILED > 0) THEN
            FUTF_EXIT_CODE = 1
        END IF

        DO I=1, NTESTS
            IF(TEST_RESULTS(I) == 'F') THEN
                IFAILED = APPEND_INT(IFAILED, I)
            END IF
        END DO

        IF(FUTF_TOTAL-FUTF_PASSED == 0) THEN
            RETURN
        END IF

        DO I=1, SIZE(IFAILED)
            IF(TEST_NAMES(IFAILED(I)) /= "UNNAMED TEST") THEN
                IF(PRINT_NAMED_FAILED_TESTS) THEN
                    WRITE(*,*) "THE FOLLOWING TESTS FAILED: ", NEW_LINE('A')
                    PRINT_NAMED_FAILED_TESTS = .FALSE.
                END IF
                WRITE(*,*) "  - ", TEST_NAMES(IFAILED(I))
                WRITE(*,*) REPEAT(" ", 10), TRIM(INFO_STRINGS(IFAILED(I))), NEW_LINE('A')
            END IF
        END DO

    END SUBROUTINE

    SUBROUTINE TEST_SUMMARY(QUIET)
        LOGICAL, OPTIONAL :: QUIET
        CHARACTER(LEN=100) :: RESULT_STR, N_TEST_STR

        IF(.NOT. ALLOCATED(TEST_RESULTS) .OR. .NOT. ALLOCATED(INFO_STRINGS)) THEN
            IF(.NOT. PRESENT(QUIET)) THEN
                WRITE(*,*) "No Tests Found."
            END IF
            RETURN
        END IF

        IF(.NOT. PRESENT(QUIET)) THEN
            WRITE(*,*) REPEAT("-", 54)
            WRITE(N_TEST_STR, '(A, i0, A)') "GATHERED ",SIZE(TEST_RESULTS)," TESTS:"
            WRITE(*,*) TRIM(N_TEST_STR), " ", TEST_RESULTS
            WRITE(*,*) REPEAT("-", 54), NEW_LINE('A')
        END IF
        CALL FAILED_TEST_SUMMARY
        IF(.NOT. PRESENT(QUIET)) THEN
            WRITE(*,*) NEW_LINE('A')
            WRITE(RESULT_STR, '(A, i0, A, i0)') REPEAT(" ", 5)//"PASSED: ", FUTF_PASSED, "/", FUTF_TOTAL
            WRITE(*,*) REPEAT("*", 20), " TEST SUMMARY ", REPEAT("*", 20), NEW_LINE('A')
            WRITE(*,*) RESULT_STR, NEW_LINE('A')
            WRITE(*,*) REPEAT("*", 54)
        END IF

        IF(.NOT. PRESENT(QUIET)) THEN
            IF(FUTF_EXIT_CODE == 0) THEN
                STOP
            ELSE
                ERROR STOP FUTF_EXIT_CODE
            END IF
        END IF
    END SUBROUTINE

    SUBROUTINE RESET_LAST_TEST_STATUS
        CHARACTER(LEN=300) :: INFO
        IF(FUTF_EXIT_CODE == 1 .AND. TEST_RESULTS(SIZE(TEST_RESULTS)) == 'F') THEN
            FUTF_EXIT_CODE = 0
            TEST_RESULTS(SIZE(TEST_RESULTS)) = "."
            FUTF_PASSED = FUTF_PASSED + 1
            INFO_STRINGS = INFO_STRINGS(1:SIZE(INFO_STRINGS)-1)
            INFO_STRINGS = APPEND_CHAR(INFO_STRINGS, INFO, LEN(INFO))
        END IF
    END SUBROUTINE RESET_LAST_TEST_STATUS
END MODULE
