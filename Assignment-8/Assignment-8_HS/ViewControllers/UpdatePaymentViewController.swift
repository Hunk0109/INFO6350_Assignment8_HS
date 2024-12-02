import UIKit

class UpdatePaymentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var paymentId: UITextField!
    @IBOutlet var policyId: UITextField!
    @IBOutlet var paymentMethod: UITextField!
    @IBOutlet var paymentAmount: UITextField!
    @IBOutlet var paymentDate: UIDatePicker!
    @IBOutlet var paymentStatus: UITextField!
    
    private var policyIdPicker = UIPickerView()
    private var paymentStatusPicker = UIPickerView()
    private var paymentMethodPicker = UIPickerView()
    
    let insurances = InsuranceDirectory.shared.getInsurances()
    let paymentStatuses = InsuranceDirectory.paymentStatus
    let paymentMethods = InsuranceDirectory.paymentMethod
    
    var customPayment: customPayment?
    var payment: Payment? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let customPayment else {
            showAlert(title: "Warning", message: "Please select a payment.")
            return
        }
        payment = InsuranceDirectory.shared.getPayments(pay: customPayment)
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
        
        guard let payment else {
            showAlert(title: "Warning", message: "Please select a payment.")
            return
        }
        
        policyId.text = String(payment.policy_id)
        policyId.isEnabled = false
        paymentId.text = String(payment.id)
        paymentId.isEnabled = false
        paymentMethod.text = payment.payment_method
        paymentDate.date = payment.payment_date
        paymentDate.isEnabled = false
        paymentStatus.text = payment.status
        paymentAmount.text = String(payment.payment_amount)
        
        
        
        
    }
    
    @IBAction func updatePayment(_ sender: UIButton) {
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
        if let payment{
            payment.payment_method = paymentMethodText
            payment.status = paymentStatusText
            payment.payment_amount = paymentAmountDouble
            if InsuranceDirectory.shared.updatePayment(payment: payment){
            showAlert(title: "Message", message: "Payment updated successfully", handler: {_ in self.navigationController?.popViewController(animated: true)
            })
            } else{
                showAlert(title: "Error", message: "Error updating payment.")
            }
        }
    }
    @IBAction func deletePayment(_ sender: UIButton) {
        if let payment{
            if payment.status == "Processed"{
                showAlert(title: "Warning", message: "Can't delete processed payment.")
            } else {
                if let customPayment{
                    if InsuranceDirectory.shared.deletePayment(pay: customPayment){
                        showAlert(title: "Message", message: "Payment deleted successfully.",handler: {_ in self.navigationController?.popViewController(animated: true)})
                    } else {
                        showAlert(title: "Error", message: "Unable to delete payment.")
                    }
                } else {
                    showAlert(title: "Warning", message: "Please select a payment to delete.")
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
