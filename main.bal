import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/time;
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;

final jdbc:Client dbClient = check new (url = "jdbc:h2:file:./database/loandatabase", user = "test", password = "test");

public function main() returns error? {
    [LoanRequest[], LoanApproval[]] extractedData = check extract();
    [Loan[], BranchPerformance[], RegionPerformance[]] transformResult = transform(extractedData[0], extractedData[1]);
    check load(transformResult);
}

function extract() returns [LoanRequest[], LoanApproval[]]|error {
    log:printInfo("BEGIN: extract data from the sftp server");
    // Hint: Use io ballerina library and read the csv files

    string loanRequestFile = "loan_request_2024_03_22.csv";
    LoanRequest[] loanRequests;

    // download `approved_loans_2024_03_19.csv` file
    string loanApprovalsFile = "approved_loans_2024_03_22.csv";    
    LoanApproval[] loanApprovals;

    log:printInfo("END: extract data from the sftp server");
    return [loanRequests, loanApprovals];
}

function transform(LoanRequest[] loanRequests, LoanApproval[] loanApprovals)
    returns [Loan[], BranchPerformance[], RegionPerformance[]] {
    log:printInfo("START: transform data");

    // Get the unique approved loan requests by joining two csv files
    // Create an array of Loan records
    // Hint: User ballerina integrated queries and transformLoanRequest function
    Loan[] approvedLoans;

    BranchPerformance[] branchPerformance = from var {branch, loanType, grantedAmount, intrest}
        in approvedLoans
        group by branch, loanType
        select {
            id: generateId(),
            branch,
            loanType,
            totalGrants: sum(grantedAmount),
            totalIntrest: sum(intrest),
            date: todayString()
        };

    // Group the `approvedLoans` by region, loanType, date, dayOfWeek
    // Hint: User ballerina integrated queries and use `sum` function when needed
    RegionPerformance[] regionPerformance;

    log:printInfo("END: transform data");
    return [approvedLoans, branchPerformance, regionPerformance];
}

function transformLoanRequest(LoanRequest loanRequest, LoanApproval loanApproval) returns Loan {
    log:printInfo(string `START: transform loan request: ${loanRequest.loanRequestId}`);

    var {loanRequestId, amount, loanType, datetime, period, branch, status} = loanRequest;
    var {grantedAmount, intrest, period: approvedPeriod} = loanApproval;

    // date time related operations
    time:Date date = fromUtcStringToDate(datetime, USA_UTC_OFFSET_IN_SECONDS);
    string dateString = fromDateToString(date);
    DayOfWeek dayOfWeek = getDayOfWeek(date);

    // Hint: Categorize branch by region
    string region;

    // Hint: Catergorization of loans by amount and type
    LoanCatergotyByAmount loanCatergoryByAmount;

    // Hint: Calculate total interest
    decimal totalInterest;

    // Hint: Get the loan status
    LoanStatus loanStatus;

    // Hint: Get the loan type
    LoanType 'type;

    log:printInfo(string `END: transform loan request: ${loanRequest.loanRequestId}`);
    return {
        loanRequestId,
        amount,
        loanType: 'type,
        datetime,
        period,
        branch,
        status: loanStatus,
        dayOfWeek,
        region,
        date: dateString,
        grantedAmount,
        intrest: totalInterest,
        approvedPeriod,
        loanCatergoryByAmount
    };
}

function load([Loan[], BranchPerformance[], RegionPerformance[]] transformResult) returns error? {
    log:printInfo("START: loading data");
    check loadLoan(transformResult[0]);
    check loadBranchPerformance(transformResult[1]);
    check loadRegionPerformance(transformResult[2]);
    log:printInfo("END: loading data");
}

function loadRegionPerformance(RegionPerformance[] data) returns error? {
    sql:ParameterizedQuery[] insertQueries = from RegionPerformance rp in data
        select `INSERT INTO RegionPerformance 
                (id, region, loanType, date, dayOfWeek, totalGrants, totalIntrest) 
                VALUES (${rp.id}, ${rp.region}, ${rp.loanType}, 
                ${rp.date}, ${rp.dayOfWeek}, ${rp.totalGrants}, ${rp.totalIntrest})`;
   _ = check dbClient->batchExecute(insertQueries);
}

function loadBranchPerformance(BranchPerformance[] data) returns error? {
    sql:ParameterizedQuery[] insertQueries = from BranchPerformance bp in data
        select `INSERT INTO BranchPerformance (id, branch, loanType, totalGrants, totalIntrest, date) 
                VALUES (${bp.id}, ${bp.branch}, ${bp.loanType}, ${bp.totalGrants}, ${bp.totalIntrest}, ${bp.date})`;
    _ = check dbClient->batchExecute(insertQueries);
}

function loadLoan(Loan[] data) returns error? {
    sql:ParameterizedQuery[] insertQueries = from Loan loan in data
        select `INSERT INTO Loan (loanRequestId, amount, period, branch, status, loanType, 
        datetime, dayOfWeek, region, date, intrest, grantedAmount, approvedPeriod, loanCatergoryByAmount) 
        VALUES (${loan.loanRequestId}, ${loan.amount}, ${loan.period}, ${loan.branch}, ${loan.status}, ${loan.loanType}, ${loan.datetime}, ${loan.dayOfWeek}, ${loan.region}, ${loan.date}, ${loan.intrest}, ${loan.grantedAmount}, ${loan.approvedPeriod}, ${loan.loanCatergoryByAmount})`;
    _ = check dbClient->batchExecute(insertQueries);
}

function getRegion(string branch) returns string {
    return branchToRegionMap[branch] ?: "";
}
