import UIKit

class AddClaimsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var policyID: UITextField!
    @IBOutlet var claimAmount: UITextField!
    @IBOutlet var claimStatus: UITextField!
    @IBOutlet var dateofClaim: UIDatePicker!
    private let policyIdPicker = UIPickerView()
    private let claimStatusPicker = UIPickerView()
    
    let insurances = InsuranceDirectory.shared.getInsurances()
    let claimStatuses = InsuranceDirectory.claimStatus
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        policyIdPicker.delegate = self
        policyIdPicker.dataSource = self
        policyID.inputView = policyIdPicker
        
        claimStatusPicker.delegate = self
        claimStatusPicker.dataSource = self
        claimStatus.inputView = claimStatusPicker
        
        claimStatusPicker.selectRow(0, inComponent: 0, animated: true)
        claimStatus.text = claimStatuses[0]
        if !insurances.isEmpty{
            policyIdPicker.selectRow(0, inComponent: 0, animated: true)
            policyID.text = "\(insurances[0].id)"
        }
    }
    
    @IBAction func addClaims() {
        guard let policyID = policyID.text, !policyID.isEmpty, let policyIDInt = Int(policyID) else {
            showAlert(title: "Warning", message: "Please enter a valid policy ID")
            return
        }
        guard let insurance = insurances.first(where: { $0.id == policyIDInt }) else {
            showAlert(title: "Warning", message: "Police ID not found")
            return
        }
        guard let claimAmount = claimAmount.text, !claimAmount.isEmpty, let claimAmountDouble = Double(claimAmount), claimAmountDouble > 0 else {
            showAlert(title: "Warning", message: "Please enter a valid claim amount")
            return
        }
        guard let claimStatus = claimStatus.text, !claimStatus.isEmpty,claimStatuses.contains(claimStatus) else {
            showAlert(title: "Warning", message: "Please enter a valid claim status")
            return
        }
        guard let claimDate = dateofClaim?.date, claimDate > insurance.start_date else {
            showAlert(title: "Warning", message: "Claim date must be after the insurance start date")
            return
        }
        if InsuranceDirectory.shared.addClaim(claim: Claim(id: UUID().hashValue, policy_id: policyIDInt, claim_amount: claimAmountDouble, date_of_claim: claimDate, status: claimStatus)){
            showAlert(title: "Message", message: "Claim added successfully")
            reset()
        } else{
            showAlert(title: "Warning", message: "Can't add claim")
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func reset(){
        claimAmount.text = ""
        dateofClaim.date = Date()
        claimStatus.text = claimStatuses[0]
        if !insurances.isEmpty{
            policyIdPicker.selectRow(0, inComponent: 0, animated: true)
            policyID.text = "\(insurances[0].id)"
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
        } else {
            return claimStatuses.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView == claimStatusPicker {
            return claimStatuses[row]
        }
        else {
            return "\(insurances[row].id)"
        }
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == policyIdPicker{
            policyID.text = "\(insurances[row].id)"
            policyIdPicker.resignFirstResponder()
        } else {
            let selectedClaimStatus = claimStatuses[row]
            claimStatus.text = selectedClaimStatus
            claimStatusPicker.resignFirstResponder()
        }
        
    }
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }

}
