import UIKit

class UpdateCustomerViewController: UIViewController {
    
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    var user: Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user else { return }
        nameTextField.text = user.name
        ageTextField.text = String(user.age)
        emailTextField.isEnabled = false
        emailTextField.text = user.email
    }
    
    
    @IBAction func updateCustomer(_ sender: UIButton) {
        print("Update Customer")
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a name")
            return
        }
        guard let age = ageTextField.text, !age.isEmpty else {
            showAlert(title: "Error", message: "Please enter an age")
            return
        }
        guard let ageInt = Int(age), ageInt > 0  else {
            showAlert(title: "Error", message: "Please enter an age greater than zero.")
            return
        }
        let emailPattern = #"^\S+@\S+\.\S+$"#
        guard emailTextField.text?.range(of: emailPattern, options: .regularExpression) != nil else {
            showAlert(title: "Warning",message:"Invalid email format. Please enter a valid email.")
            return
        }
        guard let user = user else {
            showAlert(title: "Error", message: "Please select a customer to update.")
            return
        }
        
        if InsuranceDirectory.shared.updateCustomer(update: Customer(id: user.id, name: name, age: Int(age)!, email: user.email)) {
            showAlert(title: "Success", message: "Customer updated successfully.",handler: {_ in
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            showAlert(title: "Error", message: "Customer update failed.")
        }
    }
    
    @IBAction func deleteCustomer(_ sender: UIButton) {
        print("Delete Customer")
        guard let user = user else {
            showAlert(title: "Warning", message: "No customer selected.")
            return
        }
        guard user.pastPolicies else {
            if InsuranceDirectory.shared.deleteCustomer(id: user.id){
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: "Error", message: "Customer could not be deleted.")
            }
            return
        }
        showAlert(title: "Warning", message: "Can't delete customer with active/past insurance.")
        
    }
    
    @IBAction func unwindToPreviousScreen(_ sender: UIStoryboardSegue) {
        print("Unwind to previous screen")
    }
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?=nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
    
}
