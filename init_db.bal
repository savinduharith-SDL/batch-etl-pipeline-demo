import ballerina/sql;

function initDB() returns error? {
    sql:ParameterizedQuery q1 = `DROP TABLE IF EXISTS Loan`;
    sql:ParameterizedQuery q2 = `DROP TABLE IF EXISTS RegionPerformance`;
    sql:ParameterizedQuery q3 = `DROP TABLE IF EXISTS BranchPerformance`;

    sql:ParameterizedQuery q4 = `CREATE TABLE BranchPerformance (
        id VARCHAR(191) NOT NULL,
        branch VARCHAR(191) NOT NULL,
        loanType ENUM('personal', 'educational', 'housing') NOT NULL,
        totalGrants DECIMAL(65,30) NOT NULL,
        totalInterest DECIMAL(65,30) NOT NULL,
        date VARCHAR(191) NOT NULL,
        PRIMARY KEY(id)
    )`;

    sql:ParameterizedQuery q5 = `CREATE TABLE RegionPerformance (
        id VARCHAR(191) NOT NULL,
        region VARCHAR(191) NOT NULL,
        loanType ENUM('personal', 'educational', 'housing') NOT NULL,
        date VARCHAR(191) NOT NULL,
        dayOfWeek ENUM('0', '1', '2', '3', '4', '5', '6') NOT NULL,
        totalGrants DECIMAL(65,30) NOT NULL,
        totalInterest DECIMAL(65,30) NOT NULL,
        PRIMARY KEY(id)
    )`;

    sql:ParameterizedQuery q6 = `CREATE TABLE Loan (
        loanRequestId INT NOT NULL,
        amount INT NOT NULL,
        period INT NOT NULL,
        branch VARCHAR(191) NOT NULL,
        status ENUM('approved', 'pending', 'rejected') NOT NULL,
        loanType ENUM('personal', 'educational', 'housing') NOT NULL,
        datetime VARCHAR(191) NOT NULL,
        dayOfWeek ENUM('0', '1', '2', '3', '4', '5', '6') NOT NULL,
        region VARCHAR(191) NOT NULL,
        date VARCHAR(191) NOT NULL,
        interest DECIMAL(65,30) NOT NULL,
        grantedAmount DECIMAL(65,30) NOT NULL,
        approvedPeriod INT NOT NULL,
        loanCatergoryByAmount ENUM('small', 'meduim', 'large') NOT NULL,
        PRIMARY KEY(loanRequestId)
    )`;

    _ = check dbClient->execute(q1);
    _ = check dbClient->execute(q2);
    _ = check dbClient->execute(q3);
    _ = check dbClient->execute(q4);
    _ = check dbClient->execute(q5);
    _ = check dbClient->execute(q6);
}
