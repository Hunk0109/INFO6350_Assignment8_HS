import UIKit

class UpdateClaimViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var claimID: UITextField!
    @IBOutlet var  policyID: UITextField!
    @IBOutlet var claimStatus: UITextField!
    @IBOutlet var claimAmount: UITextField!
    @IBOutlet var claimDate: UIDatePicker!
    
    let claimStatusPicker = UIPickerView()
    
    var customClaim: customClaim?
    var claim:Claim? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let customClaim else {
            showAlert(title: "Error", message: "Please select a claim")
            return
        }
        self.claim = InsuranceDirectory.shared.getClaims(clm: customClaim)
        print(claim?.id ?? 0)
        setupUI()
    }
    
    func setupUI() {
        guard let claim else {
            showAlert(title: "Error", message: "Please select a claim")
            return
        }
        claimStatusPicker.delegate = self
        claimStatusPicker.dataSource = self
        claimStatus.inputView = claimStatusPicker
        
        claimID.text = String(claim.id)
        claimID.isEnabled = false
        policyID.text = String(claim.policy_id)
        policyID.isEnabled = false
        claimStatus.text = claim.status
        claimAmount.text = String(claim.claim_amount)
        claimDate.date = claim.date_of_claim
        claimDate.isEnabled = false
    }
    
    @IBAction func updateClaim(_ sender: UIButton) {
        guard let claimAmt = claimAmount.text, !claimAmt.isEmpty else {
            showAlert(title: "Warning", message:"Please enter a claim amount")
            return
        }
        guard let claimAmountDouble = Double(claimAmt), claimAmountDouble > 0 else {
            showAlert(title: "Warning", message:"Please enter a valid claim amount")
            return
        }
        
        guard let claimStat = claimStatus.text, !claimStat.isEmpty, InsuranceDirectory.claimStatus.contains(claimStat) else {
            showAlert(title: "Warning", message: "Please enter a valid claim status")
            return
        }
        
        claim?.claim_amount = claimAmountDouble
        claim?.status = claimStat
        if InsuranceDirectory.shared.updateClaim(claim: claim!){
            showAlert(title: "Message", message:"Claim updated successfully",handler: {_ in self.navigationController?.popViewController(animated: true)
            })
        } else{
            showAlert(title: "Error", message: "Can't update claim")
        }
    
    }
    @IBAction func deleteClaim(_ sender: UIButton) {
        guard let claim else{
            showAlert(title: "Warning", message: "Please select a claim to delete")
            return
        }
        if claim.status == "Approved" {
            showAlert(title: "Warning", message: "Approved claims cannot be deleted")
        }
        guard let customClaim = customClaim else {
            showAlert(title: "Warning", message: "Please select a claim to delete")
            return
        }
        if InsuranceDirectory.shared.deleteClaim(clm: customClaim){
            showAlert(title: "Message", message: "Claim deleted successfully",handler: {_ in self.navigationController?.popViewController(animated: true)
            })
        } else{
            showAlert(title: "Error", message: "Claim could not be deleted.")
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return InsuranceDirectory.claimStatus.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return InsuranceDirectory.claimStatus[row]
      
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        claimStatus.text = InsuranceDirectory.claimStatus[row]
        claimStatus.resignFirstResponder()
        claimStatusPicker.resignFirstResponder()
    }
    
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}
