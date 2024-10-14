DROP TABLE IF EXISTS `Loan`;
DROP TABLE IF EXISTS `RegionPerformance`;
DROP TABLE IF EXISTS `BranchPerformance`;

CREATE TABLE `BranchPerformance` (
	`id` VARCHAR(191) NOT NULL,
	`branch` VARCHAR(191) NOT NULL,
	`loanType` ENUM('personal', 'educational', 'housing') NOT NULL,
	`totalGrants` DECIMAL(65,30) NOT NULL,
	`totalIntrest` DECIMAL(65,30) NOT NULL,
	`date` VARCHAR(191) NOT NULL,
	PRIMARY KEY(`id`)
);

CREATE TABLE `RegionPerformance` (
	`id` VARCHAR(191) NOT NULL,
	`region` VARCHAR(191) NOT NULL,
	`loanType` ENUM('personal', 'educational', 'housing') NOT NULL,
	`date` VARCHAR(191) NOT NULL,
	`dayOfWeek` ENUM('0', '1', '2', '3', '4', '5', '6') NOT NULL,
	`totalGrants` DECIMAL(65,30) NOT NULL,
	`totalIntrest` DECIMAL(65,30) NOT NULL,
	PRIMARY KEY(`id`)
);

CREATE TABLE `Loan` (
	`loanRequestId` INT NOT NULL,
	`amount` INT NOT NULL,
	`period` INT NOT NULL,
	`branch` VARCHAR(191) NOT NULL,
	`status` ENUM('approved', 'pending', 'rejected') NOT NULL,
	`loanType` ENUM('personal', 'educational', 'housing') NOT NULL,
	`datetime` VARCHAR(191) NOT NULL,
	`dayOfWeek` ENUM('0', '1', '2', '3', '4', '5', '6') NOT NULL,
	`region` VARCHAR(191) NOT NULL,
	`date` VARCHAR(191) NOT NULL,
	`intrest` DECIMAL(65,30) NOT NULL,
	`grantedAmount` DECIMAL(65,30) NOT NULL,
	`approvedPeriod` INT NOT NULL,
	`loanCatergoryByAmount` ENUM('small', 'meduim', 'large') NOT NULL,
	PRIMARY KEY(`loanRequestId`)
);
