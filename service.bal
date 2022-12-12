import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerina/log;

type identityCheckResponse record {
    boolean validity;
    citizenDetails citizenData?;
};

type citizenDetails record {
    string address?;
    string dateOfBirth?;
    string fullName?;
    string nic?;
};

configurable string dbName = ?;
configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get gramaapp/identitycheck/[string id]() returns error?|identityCheckResponse {

        log:printInfo("Received identity check request for ID no : " + id);
        mysql:Client mysqlEp = check new (host = dbHost, port = 3306,
        user = dbUser, password = dbPassword, database = dbName);

        sql:ParameterizedQuery countQuery = `SELECT COUNT(*) FROM citizen where nic = ${id}`;
        sql:ParameterizedQuery detailsQuery = `SELECT * FROM citizen where nic = ${id}`;

        int fetchedRecords = check mysqlEp->queryRow(countQuery);
        if (fetchedRecords == 0) {
            identityCheckResponse response = {validity: false};
            return response;
        }
        citizenDetails retrievedData = check mysqlEp->queryRow(detailsQuery);
        identityCheckResponse response = {validity: true, citizenData: retrievedData};
        return response;

    }
}
