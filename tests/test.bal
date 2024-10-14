import ballerina/sql;
import ballerina/test;
import ballerinax/h2.driver as _;

type Count record {|
    int count;
|};

@test:BeforeSuite
function runETL() returns error? {
    check main();
}

@test:Config
function testBranchPerformance() returns error? {
    stream<Count, sql:Error?> branchPerfCountStrm = dbClient->query(
        `SELECT COUNT(*) as count FROM BranchPerformance`);
    record {|Count value;|}? actualBranchPerfCount = check branchPerfCountStrm.next();
    if actualBranchPerfCount !is () {
        test:assertEquals(actualBranchPerfCount.value.count, 51,
                "incorrect branch performance entry count");
    }
}

@test:Config
function testRegionPerformance() returns error? {
    stream<Count, sql:Error?> regionPerfCountStrm = dbClient->query(
        `SELECT COUNT(*) as count FROM RegionPerformance`);
    record {|Count value;|}? actualRegionPerfCount = check regionPerfCountStrm.next();
    if actualRegionPerfCount !is () {
        test:assertEquals(actualRegionPerfCount.value.count, 57,
                "incorrect region performance entry count");
    }
}

@test:Config
function testLoan() returns error? {
    stream<Count, sql:Error?> loanCountStrm = dbClient->query(
        `SELECT COUNT(*) as count FROM Loan`);
    record {|Count value;|}? loanCount = check loanCountStrm.next();
    if loanCount !is () {
        test:assertEquals(loanCount.value.count, 449,
                "incorrect loan entry count");
    }
}
