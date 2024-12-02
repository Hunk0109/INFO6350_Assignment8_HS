import UIKit

class View_PaymentsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet var policyId: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var noPaymentsLabel: UILabel!
    private let policyIdPicker = UIPickerView()
    private var insurances = InsuranceDirectory.shared.getInsurances()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        insurances = InsuranceDirectory.shared.getInsurances()
        setupUI()
    }
    private func setupUI() {
        policyIdPicker.delegate = self
        policyIdPicker.dataSource = self
        policyId.inputView = policyIdPicker
        
        scrollView.isHidden = true
        noPaymentsLabel.isHidden = false
        
    }
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = insurances.count
        if count == 0 {
            if pickerView.subviews.filter({ $0 is UILabel }).isEmpty {
                let noDataLabel = UILabel(frame: pickerView.bounds)
                noDataLabel.text = "No Insurances available."
                noDataLabel.textAlignment = .center
                pickerView.addSubview(noDataLabel)
            }
        }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return "\(insurances[row].id)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        policyId.text = "\(insurances[row].id)"
        policyId.resignFirstResponder()
    }
    
    @IBAction func viewPayments(_ sender: UIButton) {
        policyId.resignFirstResponder()
        policyIdPicker.resignFirstResponder()
        guard let policyId = policyId.text, let policyIdInt = Int(policyId) else {
            showAlert(title: "Error", message: "Please enter a policy id.")
            return
        }
        guard let insurance = insurances.first(where: { $0.id == policyIdInt }) else {
            showAlert(title: "Error", message: "Please enter a valid policy id.")
            return
        }
        if insurance.payments.isEmpty {
            print("Empty payments")
            scrollView.isHidden = true
            noPaymentsLabel.isHidden = false
            return
        }
        scrollView.isHidden = false
        noPaymentsLabel.isHidden = true
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.setContentOffset(.zero, animated: false)
        
        var previousCard:PaymentCardView? = nil
        for payment in insurance.payments {
            let paymentLabel = PaymentCardView(payment: payment,action: action)
            scrollView.addSubview(paymentLabel)
            paymentLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                paymentLabel.topAnchor.constraint(equalTo:previousCard?.bottomAnchor ?? scrollView.topAnchor, constant: 2),
                paymentLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                paymentLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                paymentLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                paymentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            previousCard = paymentLabel
        }
        if let lastCard = previousCard {
            scrollView.bottomAnchor.constraint(equalTo: lastCard.bottomAnchor, constant: 16).isActive = true
        }
        
    }
    func action(paymentId:Int,policyId:Int){
        let customPaymentId = customPayment(payment_id: paymentId, policy_id: policyId)
        self.performSegue(withIdentifier: "UpdatePaymentScreen", sender: customPaymentId)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdatePaymentScreen" {
            if let destinationVC = segue.destination as? UpdatePaymentViewController {
                let payment = sender as! customPayment
                destinationVC.customPayment = payment
            }
        }
    }
    
    
}
class PaymentCardView: UIView {
    private let payment: Payment
    private let action: ((Int, Int) -> ())
    
    private let claimId = UILabel()
    private let policyId = UILabel()
    private let claimAmount = UILabel()
    private let dateOfClaim = UILabel()
    private let paymentMethod = UILabel()
    private let status = UILabel()
    
    
    init(payment: Payment, action: @escaping ((Int, Int) -> ())) {
        self.action = action
        self.payment = payment
        super.init(frame: .zero)
        
        setupLabels()
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        claimId.text = "Payment Id: \(payment.id)"
        policyId.text = "Policy Id: \(payment.policy_id)"
        claimAmount.text = "Payment Amount: \(payment.payment_amount)"
        dateOfClaim.text = "Date of Payment: \(payment.payment_date)"
        paymentMethod.text = "Payment Method: \(payment.payment_method)"
        status.text = "Payment Status: \(payment.status)"
        
        claimId.font = UIFont.boldSystemFont(ofSize: 14)
        policyId.font = UIFont.boldSystemFont(ofSize: 14)
        claimAmount.font = UIFont.boldSystemFont(ofSize: 14)
        dateOfClaim.font = UIFont.boldSystemFont(ofSize: 14)
        status.font = UIFont.boldSystemFont(ofSize: 14)
        paymentMethod.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    @objc private func cardTapped() {
        action(payment.id, payment.policy_id)
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [claimId, policyId, claimAmount, dateOfClaim, paymentMethod,status])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.backgroundColor = .lightGray
        stackView.layer.cornerRadius = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
