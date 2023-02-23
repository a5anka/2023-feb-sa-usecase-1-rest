import ballerina/http;
import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;

type Item record {|
    int id;
    string title;
    string description?;
    string includes?;
    string intended_for?;
    string color?;
    string material?;
    decimal price;
|};

mysql:Options mysqlOptions = {
    connectTimeout: 100,
    socketTimeout: 100,
    ssl: {
        mode: mysql:SSL_REQUIRED
    }
};

sql:ConnectionPool dbPool = {
 maxOpenConnections: 3
};

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database="asankaab_ecommerce_db", 
    options = mysqlOptions, connectionPool = dbPool
);

# A service representing a network-accessible API
# bound to port `9090`.
service /items on new http:Listener(9090) {

    # A resource for generating greetings
    # + return - string name with hello message or error
    resource function get .() returns Item[]|error {
        return getAllItems();
    }
}

isolated function getAllItems() returns Item[]|error {
    Item[] items = [];
    stream<Item, error?> resultStream = dbClient->query(
        `SELECT * FROM items`
    );
    check from Item item in resultStream
        do {
            items.push(item);
        };
    check resultStream.close();
    return items;
}