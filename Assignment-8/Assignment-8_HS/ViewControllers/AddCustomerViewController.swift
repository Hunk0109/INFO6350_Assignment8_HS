import UIKit

class AddCustomerViewController: UIViewController {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addCustomer(_ sender: UIButton) {
        print("Customer Added")
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
        InsuranceDirectory.shared.addCustomer(customer: Customer(id: UUID().hashValue, name: name, age: ageInt, email: emailTextField.text!))
        print("Customer directory updated!!")
        showAlert(title: "Success", message: "Customer added successfully.")
        nameTextField.text = ""
        ageTextField.text = ""
        emailTextField.text = ""
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
