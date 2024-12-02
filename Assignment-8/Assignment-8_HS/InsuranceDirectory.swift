import Foundation
class InsuranceDirectory{
    private var insurance: [Insurance]
    private var customer: [Customer]
    private var claims: [Claim]
    static let insuranceTypes: [String] = ["Auto", "Home", "Life", "Health", "Travel"]
    static let claimStatus: [String] = ["Pending","Approved","Denied"]
    static let paymentMethod:[String] = ["Cash","Credit","Bank Transfer"]
    static let paymentStatus:[String] = ["Pending","Processed","Failed"]
    private var dbHelper: DatabaseHelper
    private init (){
        self.dbHelper = DatabaseHelper()
        self.customer = dbHelper.readCustomers()
        self.insurance = dbHelper.readInsurances()
        self.claims = dbHelper.getCliams()
        populateClaims()
        populatePayments()
    }
    static let shared = InsuranceDirectory()
    
    func addInsurance(i: Insurance)->Bool{
        let c = customer.first(where: { $0.id == i.customer_id })!
        
        if let id = dbHelper.addInsurance(i){
            if !c.pastPolicies{
                c.pastPolicies = true
                if !dbHelper.updateCustomer(customer: c){
                    return false
                }
            }
            i.id = id
            self.insurance.append(i)
            return true
        }
        return false
    }
    
    func addCustomer(customer: Customer){
        let id = dbHelper.addCustomer(customer)
        if let id{
            customer.id = id
        }
        self.customer.append(customer)
    }
    func getInsurance(id: Int) -> Insurance?{
        return insurance.first(where: { $0.id == id })
    }
    func getCustomer(id: Int) -> Customer?{
        return customer.first(where: { $0.id == id })
    }
    func getInsurances() -> [Insurance]{
        return insurance
    }
    func deleteInsurance(id: Int)->Bool{
        if dbHelper.deleteInsurance(id){
            insurance.removeAll(where: { $0.id == id })
            NotificationCenter.default.post(name: Notification.Name("InsuranceDataUpdated"), object: nil)
            return true
        }
        return false
    }
    func updateInsurance(update: Insurance)->Bool{
        let a = insurance.first(where: { $0.id == update.id })!
        a.policy_type = update.policy_type
        a.premium_amount = update.premium_amount
        a.end_date = update.end_date
        if dbHelper.updateInsurance(a){
            NotificationCenter.default.post(name: Notification.Name("InsuranceDataUpdated"), object: nil)
            return true
        }
        return false
    }
    func getCustomers() -> [Customer]{
        return customer
    }
    func updateCustomer(update: Customer)->Bool{
        let a = customer.first(where: { $0.id == update.id })!
        a.name = update.name
        a.age = update.age
        if dbHelper.updateCustomer(customer: a){
            NotificationCenter.default.post(name: Notification.Name("CustomerDataUpdated"), object: nil)
            return true
        }
        return false
    }
    func deleteCustomer(id: Int)->Bool{
        customer.removeAll(where: { $0.id == id })
        print(customer.count)
        if dbHelper.deleteCustomer(id: id){
            NotificationCenter.default.post(name: Notification.Name("CustomerDataUpdated"), object: nil)
            return true
        }
        return false
    }
    
    func addClaim(claim: Claim) ->Bool {
        let i = getInsurance(id: claim.policy_id)
        guard let i = i else {
            return false
        }
        if let id = dbHelper.addClaim(claim){
            claim.id = id
            i.claims.append(claim)
            return true
        }
        return false
        
    }
    
    func getClaims(clm:customClaim) -> Claim{
        let i = getInsurance(id: clm.policy_id)
        let c = i?.claims.first(where: { $0.id == clm.claim_id })
        return c!
    }
    func getClaims() -> [Claim]{
        return claims
    }
    func deleteClaim(clm:customClaim)->Bool{
        let i = getInsurance(id: clm.policy_id)
        if dbHelper.deleteClaim(clm.claim_id){
            i?.claims.removeAll(where: { $0.id == clm.claim_id })
            return true
        }
        return false
    }
    
    func addPayment(payment: Payment) ->Bool {
        let i = getInsurance(id: payment.policy_id)
        guard let i = i else {
            return false
        }
        guard let id = dbHelper.addPayment(payment) else {
            return false
        }
        payment.id = id
        i.payments.append(payment)
        return true
    }
    
    func getPayments(pay:customPayment) -> Payment{
        let i = getInsurance(id: pay.policy_id)
        let p = i?.payments.first(where: { $0.id == pay.payment_id })
        return p!
    }
    
    func deletePayment(pay:customPayment)->Bool{
        let i = getInsurance(id: pay.policy_id)
        if dbHelper.deletePayment(pay.payment_id){
            i?.payments.removeAll(where: { $0.id == pay.payment_id })
            return true
        }
        return false
    }
    
    func updateClaim(claim: Claim)->Bool{
        return dbHelper.updateClaim(claim: claim)
    }
    func updatePayment(payment: Payment)->Bool{
        return dbHelper.updatePayment(payment)
    }
    func populateClaims(){
        print("Populating Claims")
        for c in self.claims{
            guard let i = getInsurance(id: c.policy_id) else{
                continue
            }
            i.claims.append(c)
        }
    }
    func populatePayments(){
        let payments = dbHelper.getPayments()
        print("Populating Payments")
        for p in payments{
            guard let i = getInsurance(id: p.policy_id) else{
                continue
            }
            i.payments.append(p)
        }
    }
}
class Insurance{
    var id: Int
    var customer_id: Int
    var policy_type: String
    var premium_amount: Double
    var start_date: Date
    var end_date: Date
    var claims:[Claim]
    var payments:[Payment]
    
    init(id: Int, customer_id: Int, policy_type: String, premium_amount: Double, start_date: Date, end_date: Date){
        self.id = id
        self.customer_id = customer_id
        self.policy_type = policy_type
        self.premium_amount = premium_amount
        self.start_date = start_date
        self.end_date = end_date
        self.claims = []
        self.payments = []
    }
}

class Customer{
    var id: Int
    var name: String
    var age: Int
    var email: String
    var pastPolicies: Bool
    
    init(id: Int, name: String, age: Int, email: String){
        self.id = id
        self.name = name
        self.age = age
        self.email = email
        self.pastPolicies = false
    }
}

class Claim{
    var id: Int
    var policy_id: Int
    var claim_amount: Double
    var date_of_claim: Date
    var status: String
    
    init(id: Int, policy_id: Int, claim_amount: Double, date_of_claim: Date, status: String){
        self.id = id
        self.policy_id = policy_id
        self.claim_amount = claim_amount
        self.date_of_claim = date_of_claim
        self.status = status
    }
}

class Payment{
    var id: Int
    var policy_id: Int
    var payment_amount: Double
    var payment_date: Date
    var payment_method: String
    var status: String
    
    init(id: Int, policy_id: Int, payment_amount: Double, payment_date: Date, payment_method: String, status: String) {
        self.id = id
        self.policy_id = policy_id
        self.payment_amount = payment_amount
        self.payment_date = payment_date
        self.payment_method = payment_method
        self.status = status
    }
}

class customClaim{
    var claim_id: Int
    let policy_id: Int
    init(claim_id: Int, policy_id: Int) {
        self.claim_id = claim_id
        self.policy_id = policy_id
    }
}

class customPayment{
    let payment_id: Int
    let policy_id: Int
    init(payment_id: Int, policy_id: Int) {
        self.payment_id = payment_id
        self.policy_id = policy_id
    }
}
