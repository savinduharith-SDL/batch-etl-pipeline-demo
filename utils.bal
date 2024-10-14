import ballerina/log;
import ballerina/time;
import ballerina/uuid;

function fromUtcStringToDate(string utcString, decimal offset) returns time:Date {
    do {
        time:Utc utcTime = check time:utcFromString(utcString);
        time:Utc localDateInUtc = time:utcAddSeconds(utcTime, offset);
        string localDateInUtcString = time:utcToString(localDateInUtc);
        int year = check int:fromString(localDateInUtcString.substring(0, 4));
        int month = check int:fromString(localDateInUtcString.substring(5, 7));
        int day = check int:fromString(localDateInUtcString.substring(8, 10));
        return {year, month, day};
    } on fail error e {
        log:printError(string `failed to parse utc string : ${utcString} error: ${e.message()}`);
        return fromUtcStringToDate(time:utcToString(time:utcNow()), 0);
    }
}

function fromDateToString(time:Date date) returns string => string `${date.year}-${date.month}-${date.day}`;

function getLoanCategoryByAmount(int amount, string loanType) returns LoanCatergotyByAmount {
    match loanType {
        PERSONAL => {
            if amount <= 10000 {
                return SMALL_LOAN;
            } else if amount <= 50000 {
                return MEDUIM_LOAN;
            }
            return LARGE_LOAN;
        }
        EDUCATIONAL => {
            if amount <= 15000 {
                return SMALL_LOAN;
            } else if amount <= 75000 {
                return MEDUIM_LOAN;
            }
            return LARGE_LOAN;
        }
        HOUSING => {
            if amount <= 20000 {
                return SMALL_LOAN;
            } else if amount <= 100000 {
                return MEDUIM_LOAN;
            }
            return LARGE_LOAN;
        }
        _ => {
            return LARGE_LOAN;
        }
    }
}

function todayString() returns
    string => fromDateToString(fromUtcStringToDate(time:utcToString(time:utcNow()), USA_UTC_OFFSET_IN_SECONDS));

function generateId() returns string => uuid:createType1AsString();

function getDayOfWeek(time:Date date) returns DayOfWeek {
    time:DayOfWeek dayOfWeek = time:dayOfWeek(date);
    match dayOfWeek {
        0 => {
            return "0";
        }
        1 => {
            return "1";
        }
        2 => {
            return "2";
        }
        3 => {
            return "3";
        }
        4 => {
            return "4";
        }
        5 => {
            return "5";
        }
        6 => {
            return "6";
        }
        _ => {
            panic error("Invalid day of week");
        }
    }
}

function getLoanType(string loanType) returns LoanType {
    if loanType == HOUSING {
        return HOUSING;
    } else if loanType == PERSONAL {
        return PERSONAL;
    }
    return EDUCATIONAL;
}

function getLoanStatus(string status) returns LoanStatus {
    if status == APPORVED {
        return APPORVED;
    } else if status == PENDING {
        return PENDING;
    }
    return REJECTED;
}
