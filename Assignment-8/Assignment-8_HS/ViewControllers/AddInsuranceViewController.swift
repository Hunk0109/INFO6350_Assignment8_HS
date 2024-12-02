import UIKit

class AddInsuranceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    @IBOutlet var policyType:UITextField!
    @IBOutlet var premium:UITextField!
    @IBOutlet var startDate:UIDatePicker!
    @IBOutlet var endDate:UIDatePicker!
    @IBOutlet var customerID:UITextField!
    private var customerList = InsuranceDirectory.shared.getCustomers()
    private var policyTypes = InsuranceDirectory.insuranceTypes
    private let policyPicker = UIPickerView()
    private let customerPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        customerPicker.delegate = self
        customerPicker.dataSource = self
        customerID.inputView = customerPicker
        
        policyPicker.delegate = self
        policyPicker.dataSource = self
        policyType.inputView = policyPicker
        
        policyPicker.selectRow(0, inComponent: 0, animated: false)
        policyType.text = policyTypes[0]
        if !customerList.isEmpty {
            customerPicker.selectRow(0, inComponent: 0, animated: false)
            customerID.text = "\(customerList[0].id)"
        }
    }
    
    @IBAction func addInsurance() {
        guard let customerIDText = customerID.text, !customerIDText.isEmpty else {
            showAlert(title: "Warning", message: "Please select a customer.")
            return
        }
        guard let customerIDInt=Int(customerIDText) else {
            showAlert(title: "Warning", message: "Invalid customer ID format.")
            return
        }
        guard InsuranceDirectory.shared.getCustomer(id: customerIDInt) != nil else {
            showAlert(title: "Warning", message: "Invalid customer ID.")
            return
        }
        
        guard let policyTypeText = policyType.text, !policyTypeText.isEmpty,policyTypes.contains(policyTypeText) else {
            showAlert(title: "Warning", message: "Please select a valid policy type.")
            return
        }
        guard let premiumText = premium.text, !premiumText.isEmpty else {
            showAlert(title: "Warning", message: "Please enter a premium.")
            return
        }
        guard let premiumDouble = Double(premiumText) else {
            showAlert(title: "Warning", message: "Invalid premium format.")
            return
        }
        
        guard premiumDouble > 0 else {
            showAlert(title: "Warning", message: "Premium must be greater than zero.")
            return
        }
        
        let startDatePicked = startDate.date
        let endDatePicked = endDate.date
        
        if startDatePicked >= endDatePicked {
            showAlert(title: "Warning", message: "Start date must be before end date.")
            return
        }
        
        let isSameDay = Calendar.current.isDate(startDatePicked, inSameDayAs: endDatePicked)
        let today = Calendar.current.startOfDay(for: Date())
        
        if startDatePicked < today || endDatePicked < today {
            showAlert(title: "Warning", message: "Start and end dates cannot be in the past.")
            return
        }
        
        if isSameDay {
            showAlert(title: "Warning", message: "Start date and end date cannot be the same day.")
            return
        }
        
        if InsuranceDirectory.shared.addInsurance(i: Insurance(id:UUID().hashValue,customer_id: customerIDInt, policy_type: policyTypeText, premium_amount: premiumDouble, start_date: startDatePicked, end_date: endDatePicked)){
            showAlert(title: "Success", message: "Insurance added successfully.")
        } else {
            showAlert(title: "Error", message: "Unable to add insurance.")
        }
        print("Insurance count: \(InsuranceDirectory.shared.getInsurances().count)")
        policyType.text = ""
        customerID.text = ""
        premium.text = ""
        startDate.date = Date()
        endDate.date = Date()
        policyPicker.selectRow(0, inComponent: 0, animated: false)
        policyType.text = policyTypes[0]
        if !customerList.isEmpty {
            customerPicker.selectRow(0, inComponent: 0, animated: false)
            customerID.text = "\(customerList[0].id)"
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == customerPicker {
            let count = customerList.count
            if count == 0 {
                if pickerView.subviews.filter({ $0 is UILabel }).isEmpty {
                    let noDataLabel = UILabel(frame: pickerView.bounds)
                    noDataLabel.text = "No customers available."
                    noDataLabel.textAlignment = .center
                    pickerView.addSubview(noDataLabel)
                }
            }
            return count
        } else {
            return policyTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if(pickerView == customerPicker){
            return "\(customerList[row].name)"
        } else {
            return policyTypes[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == policyPicker) {
            policyType.text = policyTypes[row]
            policyPicker.resignFirstResponder()
        } else {
            customerID.text = "\(customerList[row].id)"
            customerPicker.resignFirstResponder()
        }
    }

}
