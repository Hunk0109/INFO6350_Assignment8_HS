import Foundation
import SQLite3


class DatabaseHelper {
    private var db: OpaquePointer?
    private var path: String = "insurance.sqlite"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    init(){
        db = createDB()
        createTable()
    }
    
    
    func createDB()->OpaquePointer?{
        var db:OpaquePointer?
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
            print("Error opening database")
            return nil
        } else{
            print("Database opened successfully")
            return db
        }
    }
    
    func createTable() {
        let createCustomersTableQuery = Query.createCustomersTableQuery
        let createInsuranceTableQuery = Query.createInsuranceTableQuery
        let createClaimsTableQuery = Query.createClaimsTableQuery
        let createPaymentsTableQuery = Query.createPaymentsTableQuery
        
        // Function to execute a single CREATE TABLE query
        func executeCreateTableQuery(_ query: String) {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Table created successfully")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                    print("Error creating table: \(errmsg)")
                }
            } else {
                print("Error preparing query")
            }
            sqlite3_finalize(statement)
        }
        
        // Execute each CREATE TABLE query
        executeCreateTableQuery(createCustomersTableQuery)
        executeCreateTableQuery(createInsuranceTableQuery)
        executeCreateTableQuery(createClaimsTableQuery)
        executeCreateTableQuery(createPaymentsTableQuery)
    }
    
    func addCustomer(_ customer: Customer)->Int?{
        let addCustomerQuery = Query.addCustomerQuery
        var statement:OpaquePointer?
        var rowId:Int? = nil
        if sqlite3_prepare_v2(self.db,addCustomerQuery,-1,&statement,nil)==SQLITE_OK{
            let name = customer.name
            let email = customer.email
            let age = customer.age
            var pastPolicies = 0
            if customer.pastPolicies{
                pastPolicies = 1
            }
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(age))
            sqlite3_bind_text(statement, 3, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(pastPolicies))
            if sqlite3_step(statement)==SQLITE_DONE{
                rowId = Int(sqlite3_last_insert_rowid(db))
                print("Customer added successfully")
            }else{
                print("Error adding customer")
            }
        } else {
            print("Add customer query failed")
        }
        return rowId
    }
    
    func readCustomers() -> [Customer] {
        var customers: [Customer] = []
        let readCustomersQuery = Query.readCustomersQuery
        var statement:OpaquePointer?
        if sqlite3_prepare_v2(self.db,readCustomersQuery,-1,&statement,nil)==SQLITE_OK{
            while sqlite3_step(statement)==SQLITE_ROW{
                let id = Int(sqlite3_column_int(statement,0))
                let name = String(cString: sqlite3_column_text(statement,1))
                let age = Int(sqlite3_column_int(statement, 2))
                let email = String(cString: sqlite3_column_text(statement, 3))
                let pastPolicy = Int(sqlite3_column_int(statement, 4))
                let customer = Customer(id: id, name: name, age: age, email: email)
                if pastPolicy == 1{
                    customer.pastPolicies = true
                }
                customers.append(customer)
                
            }
        } else{
            print("Error reading customers")
        }
        return customers
    }
    
    func readCustomer(id: Int) -> Customer? {
        let readCustomerQuery = "SELECT * FROM Customers WHERE id = \(id)"
        var statement:OpaquePointer?
        var customer: Customer?
        if sqlite3_prepare_v2(self.db,readCustomerQuery,-1,&statement,nil)==SQLITE_OK{
            while sqlite3_step(statement)==SQLITE_ROW{
                let id = Int(sqlite3_column_int(statement,0))
                let name = String(cString: sqlite3_column_text(statement,1))
                let age = Int(sqlite3_column_int(statement,2))
                let email = String(cString: sqlite3_column_text(statement,3))
                let pastPolicies = Int(sqlite3_column_int(statement, 4))
                let pastPoliciesBool = pastPolicies == 1 ? true : false
                customer = Customer(id: id, name: name, age: age, email: email)
                if pastPoliciesBool{
                    customer?.pastPolicies = true
                }
            }
            
        } else{
            print("Error reading customer")
        }
        return customer
    }
    
    func updateCustomer(customer: Customer)->Bool{
        let updateCustomerQuery = "UPDATE Customers SET name = '\(customer.name)', age = \(customer.age), email = '\(customer.email)', pastPolicies = \(customer.pastPolicies ? 1 : 0) WHERE id = \(customer.id)"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(self.db, updateCustomerQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Customer updated successfully")
                return true
            } else{
                print("Customer update failed")
            }
        } else{
            print("Customer update query failed")
        }
        return false
    }
    
    func deleteCustomer(id: Int)->Bool{
        let deleteCustomerQuery = "DELETE FROM Customers WHERE id = \(id)"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(self.db, deleteCustomerQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Customer deleted successfully")
                return true
            } else{
                print("Customer delete failed")
            }
        } else{
            print("Error while preparing delete customer query")
        }
        return false
    }
    
    func addInsurance(_ insurance:Insurance)->Int?{
        let addInsuranceQuery = Query.addInsuranceQuery
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(self.db, addInsuranceQuery, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            sqlite3_bind_int(statement, 1, Int32(insurance.customer_id))
            sqlite3_bind_text(statement, 2, (insurance.policy_type as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 3, insurance.premium_amount)
            sqlite3_bind_text(statement, 4, (dateFormatter.string(from: insurance.start_date) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (dateFormatter.string(from: insurance.end_date) as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Insurance added successfully")
                return Int(sqlite3_last_insert_rowid(db))
            } else{
                print("Error adding insurance")
            }
        } else{
            let errmsg = String(cString: sqlite3_errmsg(self.db)!) // Get detailed error message
            print("Error adding insurance: \(errmsg)")
        }
        return nil
    }
    
    func readInsurances() -> [Insurance] {
        var insurances: [Insurance] = []
        let readInsurancesQuery = Query.readInsurancesQuery
        var statement: OpaquePointer?
        
        
        if sqlite3_prepare_v2(self.db, readInsurancesQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int64(statement, 0))
                let customerId = Int(sqlite3_column_int64(statement, 1))
                let policyType = String(cString: sqlite3_column_text(statement, 2))
                let premiumAmount = Double(sqlite3_column_double(statement, 3))
                let policyStartDate = String(cString: sqlite3_column_text(statement, 4))
                let policyEndDate = String(cString: sqlite3_column_text(statement, 5))
                insurances.append(Insurance(id: id, customer_id: customerId, policy_type: policyType, premium_amount: premiumAmount, start_date: dateFormatter.date(from: policyStartDate) ?? Date(), end_date: dateFormatter.date(from: policyEndDate) ?? Date()))
            }
        } else {
            print("Error preparing read insurances query")
        }
        return insurances
    }
    
    func updateInsurance(_ insurance: Insurance)->Bool {
        let updateQuery = Query.updateInsuranceQuery
        var statement: OpaquePointer?
        
        
        if sqlite3_prepare_v2(self.db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (insurance.policy_type as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, insurance.premium_amount)
            sqlite3_bind_text(statement, 3, (dateFormatter.string(from: insurance.end_date) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(insurance.id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Insurance updated successfully")
                return true
            } else {
                print("Error while updating insurance")
            }
        } else {
            print("Error while preparing update query")
        }
        return false
    }
    
    func deleteInsurance(_ id:Int)->Bool {
        let deleteQuery = Query.deleteInsuranceQuery
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Insurance deleted successfully.")
                return true
            }else {
                print("Error deleting insurance")
            }
        } else{
            print("Error preparing delete query")
        }
        return false
    }
    
    func addClaim(_ claim:Claim)->Int? {
        let insertQuery = Query.addClaimQuery
        var statement: OpaquePointer?
        
        
        
        if sqlite3_prepare_v2(self.db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(claim.policy_id))
            sqlite3_bind_double(statement, 2, claim.claim_amount)
            sqlite3_bind_text(statement, 3, (dateFormatter.string(from: claim.date_of_claim) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (claim.status as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Claim added successfully")
                return Int(sqlite3_last_insert_rowid(self.db))
            } else{
                print("Error while adding claim")
            }
        } else {
            print("Error while preparing add claim query")
        }
        return nil
    }
    
    func getCliams()->[Claim] {
        var claims:[Claim] = []
        let query = Query.readClaimsQuery
        var statement: OpaquePointer?
        
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int64(statement, 0))
                let policy_id = Int(sqlite3_column_int64(statement, 1))
                let amount = Double(sqlite3_column_double(statement, 2))
                let date = String(cString: sqlite3_column_text(statement, 3))
                let status = String(cString: sqlite3_column_text(statement, 4))
                let claim = Claim(id: id, policy_id: policy_id, claim_amount: amount, date_of_claim: dateFormatter.date(from: date) ?? Date(), status: status)
                claims.append(claim)
            }
        } else {
            print("Error while preparing get claim")
        }
        
        return claims
    }
    
    func updateClaim(claim:Claim)->Bool {
        let updateQuery = Query.updateClaimQuery
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, claim.claim_amount)
            sqlite3_bind_text(statement, 2, (claim.status as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(claim.id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Claim updated successfully")
                return true
            } else {
                print("Error updating claim")
            }
        } else{
            print("Error preparing update query")
        }
        return false
    }
    func deleteClaim(_ claim_id:Int)->Bool {
        let deleteQuery = Query.deleteClaimQuery
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(claim_id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Claim deleted successfully")
                return true
            } else {
                print("Error deleting claim")
            }
        }
        return false
    }
    
    func getPayments()->[Payment]{
        let getPaymentsQuery = Query.readPaymentsQuery
        var statement: OpaquePointer?
        var payments: [Payment] = []
        
        if sqlite3_prepare_v2(self.db, getPaymentsQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int64(statement, 0))
                let policy_id = Int(sqlite3_column_int64(statement, 1))
                let payment_amount = Double(sqlite3_column_double(statement, 2))
                let payment_dateString = String(cString: sqlite3_column_text(statement, 3))
                let payment_method = String(cString: sqlite3_column_text(statement, 4))
                let status = String(cString: sqlite3_column_text(statement, 5))
                // Convert payment_dateString to Date
                let payment_date = dateFormatter.date(from: payment_dateString) ?? Date()
                
                payments.append(Payment(id: id, policy_id: policy_id, payment_amount: payment_amount, payment_date: payment_date, payment_method: payment_method, status: status))
            }
        } else {
            print("Error while preparing getPaymentsQuery")
        }
        return payments
    }
    
    func addPayment(_ payment: Payment)->Int?{
        let addPaymentQuery = Query.addPaymentQuery
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(self.db, addPaymentQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(payment.policy_id))
            sqlite3_bind_double(statement, 2, payment.payment_amount)
            let dateString = dateFormatter.string(from: payment.payment_date)
            sqlite3_bind_text(statement, 3, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (payment.payment_method as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (payment.status as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let lastInsertedId = Int(sqlite3_last_insert_rowid(self.db))
                print("Payment added successfully")
                return lastInsertedId
            } else{
                print("Error adding payment")
            }
        } else{
            print("Error while preparing add payment query")
        }
        return nil
    }
    
    func updatePayment(_ payment: Payment)->Bool{
        let updateQuery = "UPDATE Payments SET payment_amount = ?, payment_method = ?, status = ? WHERE id = ?;"
        var statement:OpaquePointer?
        if sqlite3_prepare_v2(self.db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, Double(payment.payment_amount))
            sqlite3_bind_text(statement,2,(payment.payment_method as NSString).utf8String,-1,nil)
            sqlite3_bind_text(statement,3,(payment.status as NSString).utf8String,-1,nil)
            sqlite3_bind_int(statement, 4, Int32(payment.id))
            
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Updated payment successfully")
                return true
            }else{
                let errmsg = String(cString: sqlite3_errmsg(self.db)!) 
                print("Error updating payment: \(errmsg)")
            }
        } else{
            print("Error while preparing update payment query")
        }
        return false
    }
    func deletePayment(_ paymentId:Int)->Bool{
        let deleteQuery = Query.deleteClaimQuery
        var statement:OpaquePointer?
        print("Id \(paymentId)")
        if sqlite3_prepare_v2(self.db,deleteQuery, -1, &statement, nil) == SQLITE_OK{
            sqlite3_bind_int(statement, 1, Int32(paymentId))
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Deleted payment successfully")
                return true
            }else{
                let errmsg = String(cString: sqlite3_errmsg(self.db)!) // Get SQLite error message
                print("Error deleting payment: \(errmsg)")
            }
        
        } else{
            print("Error preparing delete payment query")
        }
        return false
    }
}


