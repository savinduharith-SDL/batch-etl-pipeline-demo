type LoanRequest record {|
    int loanRequestId;
    int amount;
    int period;
    string branch;
    string datetime;
    string status;
    string loanType;
|};

type LoanApproval record {|
    int loanRequestId;
    int loanId;
    decimal interest;
    decimal grantedAmount;
    int period;
|};

type Loan record {|
    readonly int loanRequestId;
    int amount;
    int period;
    string branch;
    LoanStatus status;
    LoanType loanType;
    string datetime;
    DayOfWeek dayOfWeek;
    string region;
    string date;
    decimal interest;
    decimal grantedAmount;
    int approvedPeriod;
    LoanCatergotyByAmount loanCatergoryByAmount;
|};

type BranchPerformance record {|
    readonly string id;
    string branch;
    LoanType loanType;
    decimal totalGrants;
    decimal totalInterest;
    string date;
|};

type RegionPerformance record {|
    readonly string id;
    string region;
    LoanType loanType;
    string date;
    DayOfWeek dayOfWeek;
    decimal totalGrants;
    decimal totalInterest;
|};

enum LoanType {
    PERSONAL = "personal", 
    EDUCATIONAL = "educational", 
    HOUSING = "housing"
}

enum LoanStatus {
    APPORVED = "approved",
    PENDING = "pending",
    REJECTED = "rejected"
}

enum LoanCatergotyByAmount {
    SMALL_LOAN = "small",
    MEDUIM_LOAN = "meduim",
    LARGE_LOAN = "large"
}

enum DayOfWeek {
    SUNDAY = "0",
    MONDAY = "1",
    TUESDAY = "2",
    WEDNESDAY = "3",
    THURSDAY = "4",
    FRIDAY = "5",
    SATURDAY = "6"
}
