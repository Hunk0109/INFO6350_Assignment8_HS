import UIKit

class UpdateInsuranceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet var policyType:UITextField!
    @IBOutlet var premium:UITextField!
    @IBOutlet var startDate:UIDatePicker!
    @IBOutlet var endDate:UIDatePicker!
    @IBOutlet var customerID:UITextField!
    private let policyPicker = UIPickerView()
    private let customerPicker = UIPickerView()
    private var policyTypes = InsuranceDirectory.insuranceTypes

    var insurance:Insurance?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        guard let insurance else {
            showAlert(title: "Error", message: "No Insurance Selected")
            return
        }
        policyType.text = insurance.policy_type
        premium.text = String(insurance.premium_amount)
        startDate.date = insurance.start_date
        endDate.date = insurance.end_date
        customerID.text = String(insurance.customer_id)
        
        customerID.isEnabled = false
        startDate.isEnabled = false
    
        
        policyPicker.delegate = self
        policyPicker.dataSource = self
        policyType.inputView = policyPicker
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return policyTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return policyTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        policyType.text = policyTypes[row]
        policyPicker.resignFirstResponder()
        
    }
    @IBAction func updateInsurance(){
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
        
        if isSameDay {
            showAlert(title: "Warning", message: "Start date and end date cannot be the same day.")
            return
        }
        guard let insurance else {
            showAlert(title: "Warning", message: "Please select an insurance.")
            return
        }
        if InsuranceDirectory.shared.updateInsurance(update: Insurance(id: insurance.id, customer_id: insurance.id, policy_type: policyTypeText, premium_amount: premiumDouble, start_date: insurance.start_date, end_date:endDatePicked )){
            showAlert(title: "Success", message: "Insurance updated successfully.",handler: {_ in self.navigationController?.popViewController(animated: true)
            })
        } else{
            showAlert(title: "Error", message: "Insurance update failed.")
        }
    }
    
    @IBAction func deleteInsurance() {
        let today = Calendar.current.startOfDay(for: Date())
        guard let insurance else {
            showAlert(title: "Warning", message: "No insurance selected.")
            return
        }
        guard insurance.end_date <= today else {
            showAlert(title: "Warning", message: "Insurance cannot be deleted.")
            return
        }
        if InsuranceDirectory.shared.deleteInsurance(id: insurance.id){
            self.navigationController?.popViewController(animated: true)
        } else {
            showAlert(title: "Error", message: "Can't delete insurance.")
        }
    }
    
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }

}
