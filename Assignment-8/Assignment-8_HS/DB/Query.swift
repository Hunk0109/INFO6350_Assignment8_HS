import Foundation



struct Query: Codable {
    static let createCustomersTableQuery = """
    CREATE TABLE IF NOT EXISTS Customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        email TEXT,
        pastPolicies INTEGER
    );
    """
    
    static let createInsuranceTableQuery = """
    CREATE TABLE IF NOT EXISTS Insurance (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER,
        policy_type TEXT,
        premium_amount REAL,
        start_date TEXT,
        end_date TEXT,
        FOREIGN KEY (customer_id) REFERENCES Customers(id)
    );
    """
    
    static let createClaimsTableQuery = """
    CREATE TABLE IF NOT EXISTS Claims (
        id INTEGER PRIMARY KEY,
        policy_id INTEGER,
        claim_amount REAL,
        date_of_claim TEXT,
        status TEXT,
        FOREIGN KEY (policy_id) REFERENCES Insurance(id)
    );
    """
    
    static let createPaymentsTableQuery = """
        CREATE TABLE IF NOT EXISTS Payments (
            id INTEGER PRIMARY KEY,
            policy_id INTEGER,
            payment_amount REAL,
            payment_date TEXT,
            payment_method TEXT,
            status TEXT,
            FOREIGN KEY (policy_id) REFERENCES Insurance(id)
        );
        """
    static let addCustomerQuery = "INSERT INTO Customers (name, age, email, pastPolicies) VALUES (?, ?, ?, ?)"
    static  let readCustomersQuery = "SELECT * FROM Customers"
    static let addInsuranceQuery = "INSERT INTO Insurance (customer_id, policy_type, premium_amount, start_date, end_date) VALUES (?, ?, ?, ?,?);"
    static let readInsurancesQuery = "SELECT * FROM Insurance"
    static let updateInsuranceQuery = "UPDATE Insurance SET policy_type = ?, premium_amount = ?, end_date = ? WHERE id = ?;"
    static let deleteInsuranceQuery = "DELETE FROM Insurance WHERE id = ?;"
    
    static let addClaimQuery = "INSERT INTO Claims (policy_id, claim_amount, date_of_claim, status) VALUES (?, ?, ?, ?);"
    static let readClaimsQuery = "SELECT * FROM Claims;"
    static let updateClaimQuery = "UPDATE Claims SET claim_amount = ?, status = ? WHERE id = ?;"
    static let deleteClaimQuery = "DELETE FROM Claims WHERE id = ?;"
    
    static let addPaymentQuery = "INSERT INTO Payments (policy_id, payment_amount, payment_date, payment_method, status) VALUES (?, ?, ?, ?, ?);"
    static let readPaymentsQuery = "SELECT * FROM Payments;"
    static let updatePaymentQuery = "UPDATE Payments SET payment_amount = ?, payment_method = ?, status = ? WHERE id = ?;"
    static let deletePaymentQuery = "DELETE FROM Payments WHERE id = ?"
}
