import UIKit

class AddPaymentsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var policyId: UITextField!
    @IBOutlet var paymentMethod: UITextField!
    @IBOutlet var paymentDate: UIDatePicker!
    @IBOutlet var paymentStatus: UITextField!
    @IBOutlet var paymentAmount: UITextField!
    
    private var policyIdPicker = UIPickerView()
    private var paymentStatusPicker = UIPickerView()
    private var paymentMethodPicker = UIPickerView()
    
    let insurances = InsuranceDirectory.shared.getInsurances()
    let paymentStatuses = InsuranceDirectory.paymentStatus
    let paymentMethods = InsuranceDirectory.paymentMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        policyIdPicker.delegate = self
        policyIdPicker.dataSource = self
        policyId.inputView = policyIdPicker
        
        paymentStatusPicker.delegate = self
        paymentStatusPicker.dataSource = self
        paymentStatus.inputView = paymentStatusPicker
        
        paymentMethodPicker.delegate = self
        paymentMethodPicker.dataSource = self
        paymentMethod.inputView = paymentMethodPicker
        
        paymentStatusPicker.selectRow(0, inComponent: 0, animated: true)
        paymentMethodPicker.selectRow(0, inComponent: 0, animated: true)
        paymentMethod.text = paymentMethods[0]
        paymentStatus.text = paymentStatuses[0]
        if !insurances.isEmpty{
            policyIdPicker.selectRow(0, inComponent: 0, animated: true)
            policyId.text = "\(insurances[0].id)"
        }
    }

    @IBAction func addPayment(_ sender: UIButton) {
        guard let policyIdText = policyId.text, !policyIdText.isEmpty, let policyIdInt = Int(policyIdText), let _ = insurances.first(where: {$0.id == policyIdInt}) else {
            showAlert(title: "Warning", message: "Please enter a valid policy id")
            return
        }
        guard let paymentMethodText = paymentMethod.text, !paymentMethodText.isEmpty, InsuranceDirectory.paymentMethod.contains(paymentMethodText) else {
            showAlert(title: "Warning", message: "Please enter a valid payment method")
            return
        }
        guard let paymentStatusText = paymentStatus.text, !paymentStatusText.isEmpty, InsuranceDirectory.paymentStatus.contains(paymentStatusText) else {
            showAlert(title: "Warning", message: "Please enter a valid payment status")
            return
        }
        
        guard let paymentAmount = paymentAmount.text, !paymentAmount.isEmpty, let paymentAmountDouble = Double(paymentAmount), paymentAmountDouble > 0 else {
            showAlert(title: "Warning", message: "Please enter a valid payment amount")
            return
        }
        let payDate = paymentDate.date
        if payDate < Date(){
            showAlert(title: "Warning", message: "Please enter a valid payment date")
            return
        }
        
        if InsuranceDirectory.shared.addPayment(payment:Payment(id: UUID().hashValue, policy_id: policyIdInt, payment_amount: paymentAmountDouble, payment_date: payDate, payment_method: paymentMethodText, status: paymentStatusText))
        {
            showAlert(title:"Message", message: "Payment added successfully", handler: {_ in self.reset()})
        } else {
            showAlert(title: "Error", message: "Payment could not be added")
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func reset(){
        paymentAmount.text = ""
        paymentStatusPicker.selectRow(0, inComponent: 0, animated: true)
        paymentMethodPicker.selectRow(0, inComponent: 0, animated: true)
        paymentMethod.text = paymentMethods[0]
        paymentStatus.text = paymentStatuses[0]
        paymentDate.date = Date()
        if !insurances.isEmpty{
            policyIdPicker.selectRow(0, inComponent: 0, animated: true)
            policyId.text = "\(insurances[0].id)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == policyIdPicker {
            let count = insurances.count
            if count == 0 {
                if pickerView.subviews.filter({ $0 is UILabel }).isEmpty {
                    let noDataLabel = UILabel(frame: pickerView.bounds)
                    noDataLabel.text = "No Insurance available."
                    noDataLabel.textAlignment = .center
                    pickerView.addSubview(noDataLabel)
                }
            }
            return insurances.count
        } else if pickerView == paymentMethodPicker {
            return paymentMethods.count
        }
        
        else {
            return paymentStatuses.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView == paymentStatusPicker {
            return paymentStatuses[row]
        } else if pickerView == paymentMethodPicker {
            return paymentMethods[row]
        }
        else {
            return "\(insurances[row].id)"
        }
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == policyIdPicker{
            policyId.text = "\(insurances[row].id)"
            policyId.resignFirstResponder()
        }
        else if pickerView == paymentMethodPicker {
            let selectedPaymentMethod = paymentMethods[row]
            paymentMethod.text = selectedPaymentMethod
            paymentMethod.resignFirstResponder()
        }
        else {
            let selectedPaymentStatus = paymentStatuses[row]
            paymentStatus.text = selectedPaymentStatus
            paymentStatus.resignFirstResponder()
        }
    }
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}
