import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/time;
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;

final jdbc:Client dbClient = check new (url = "jdbc:h2:file:./database/loandatabase", user = "test", password = "test");

public function main() returns error? {
    check initDB();
    [LoanRequest[], LoanApproval[]] extractedData = check extract();
    [Loan[], BranchPerformance[], RegionPerformance[]] transformResult = transform(extractedData[0], extractedData[1]);
    check load(transformResult);
}

function extract() returns [LoanRequest[], LoanApproval[]]|error {
    log:printInfo("BEGIN: extract data from the sftp server");

    string loanRequestFile = "./resources/loan_request_2024_03_22.csv";
    LoanRequest[] loanRequests = check io:fileReadCsv(loanRequestFile);

    string loanApprovalsFile = "./resources/approved_loans_2024_03_22.csv";
    LoanApproval[] loanApprovals = check io:fileReadCsv(loanApprovalsFile);

    log:printInfo("END: extract data from the sftp server");
    return [loanRequests, loanApprovals];
}

function transform(LoanRequest[] loanRequests, LoanApproval[] loanApprovals)
    returns [Loan[], BranchPerformance[], RegionPerformance[]] {
    log:printInfo("START: transform data");

    // Perform inner join between loanRequests and loanApprovals based on loanRequestId
    Loan[] approvedLoans = from var loanRequest in loanRequests
        join var loanApproval in loanApprovals
                            on loanRequest.loanRequestId equals loanApproval.loanRequestId
        select transformLoanRequest(loanRequest, loanApproval);

    // Calculate branch performance by grouping approved loans
    BranchPerformance[] branchPerformance = from var {branch, loanType, grantedAmount, interest}
        in approvedLoans
        group by branch, loanType
        select {
            id: generateId(),
            branch,
            loanType,
            totalGrants: sum(grantedAmount),
            totalInterest: sum(interest),
            date: todayString()
        };

    // Group the approved loans by region, loanType, date, and dayOfWeek
    RegionPerformance[] regionPerformance = from var {region, loanType, grantedAmount, interest, dayOfWeek}
        in approvedLoans
        group by region, loanType, dayOfWeek
        select {
            id: generateId(),
            region,
            loanType,
            date: todayString(),
            dayOfWeek,
            totalGrants: sum(grantedAmount),
            totalInterest: sum(interest)
        };

    log:printInfo("END: transform data");
    return [approvedLoans, branchPerformance, regionPerformance];
}

function transformLoanRequest(LoanRequest loanRequest, LoanApproval loanApproval) returns Loan {
    log:printInfo(string START: transform loan request: ${loanRequest.loanRequestId});

    // Destructure fields from LoanRequest and LoanApproval
    var {loanRequestId, amount, loanType, datetime, period, branch, status} = loanRequest;
    var {grantedAmount, interest, period: approvedPeriod} = loanApproval;

    // Convert the date string to a Date object and get the day of the week
    time:Date date = fromUtcStringToDate(datetime, USA_UTC_OFFSET_IN_SECONDS);
    string dateString = fromDateToString(date);
    DayOfWeek dayOfWeek = getDayOfWeek(date);

    // Get the region based on the branch
    string region = getRegion(branch);

    // Categorize the loan by amount and loan type
    LoanCatergotyByAmount loanCatergoryByAmount = getLoanCategoryByAmount(amount, loanType);

    // Calculate total interest (if any additional computation is needed)
    decimal totalInterest = interest * grantedAmount;

    // Get the loan status and type from the enums
    LoanStatus loanStatus = getLoanStatus(status);
    LoanType 'type = getLoanType(loanType);

    log:printInfo(string END: transform loan request: ${loanRequest.loanRequestId});

    // Return the transformed Loan record
    return {
        loanRequestId: loanRequestId,
        amount: amount,
        loanType: 'type,
        datetime: datetime,
        period: period,
        branch: branch,
        status: loanStatus,
        dayOfWeek: dayOfWeek,
        region: region,
        date: dateString,
        grantedAmount: grantedAmount,
        interest: totalInterest,
        approvedPeriod: approvedPeriod,
        loanCatergoryByAmount: loanCatergoryByAmount
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
                (id, region, loanType, date, dayOfWeek, totalGrants, totalInterest) 
                VALUES (${rp.id}, ${rp.region}, ${rp.loanType}, 
                ${rp.date}, ${rp.dayOfWeek}, ${rp.totalGrants}, ${rp.totalInterest})`;
    _ = check dbClient->batchExecute(insertQueries);
}

function loadBranchPerformance(BranchPerformance[] data) returns error? {
    sql:ParameterizedQuery[] insertQueries = from BranchPerformance bp in data
        select `INSERT INTO BranchPerformance (id, branch, loanType, totalGrants, totalInterest, date) 
                VALUES (${bp.id}, ${bp.branch}, ${bp.loanType}, ${bp.totalGrants}, ${bp.totalInterest}, ${bp.date})`;
    _ = check dbClient->batchExecute(insertQueries);
}

function loadLoan(Loan[] data) returns error? {
    sql:ParameterizedQuery[] insertQueries = from Loan loan in data
        select `INSERT INTO Loan (loanRequestId, amount, period, branch, status, loanType, 
        datetime, dayOfWeek, region, date, interest, grantedAmount, approvedPeriod, loanCatergoryByAmount) 
        VALUES (${loan.loanRequestId}, ${loan.amount}, ${loan.period}, ${loan.branch}, ${loan.status}, ${loan.loanType}, ${loan.datetime}, ${loan.dayOfWeek}, ${loan.region}, ${loan.date}, ${loan.interest}, ${loan.grantedAmount}, ${loan.approvedPeriod}, ${loan.loanCatergoryByAmount})`;
    _ = check dbClient->batchExecute(insertQueries);
}

function getRegion(string branch) returns string {
    return branchToRegionMap[branch] ?: "";
}