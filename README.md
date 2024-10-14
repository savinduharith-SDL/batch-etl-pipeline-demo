# Batch ETL Pipeline Demo

This project showcases an ETL (Extract, Transform, Load) process implemented using Ballerina.
It includes two CSV files located in the resources directory, which contain data on `LoanApproval` and `LoanRequest` records.

The primary objective of this ETL pipeline is to extract approved loan details and analyze branch-wise and region-wise performance before loading the processed data into an H2 database.

The `main.bal` file includes hints to guide you in completing the ETL process flow. 

## Prerequisites

- [Ballerina](https://ballerina.io/downloads/) installed

## Run the Project

**Run the Ballerina program:**
    ```sh
    bal run
    ```

## Test the Project

**Run the tests:**
    ```sh
    bal test
    ```
