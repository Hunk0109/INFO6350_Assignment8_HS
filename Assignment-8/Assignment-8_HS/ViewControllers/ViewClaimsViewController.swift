import UIKit

class ViewClaimsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet var policyId: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var noClaimsLabel: UILabel!
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
    func setupUI() {
        policyIdPicker.delegate = self
        policyIdPicker.dataSource = self
        policyId.inputView = policyIdPicker
        
        scrollView.isHidden = true
        noClaimsLabel.isHidden = false
        
        
    }
    @IBAction func viewClaimsButtonTapped(_ sender: UIButton) {
        guard let policyId = policyId.text, let policyIdInt = Int(policyId) else {
            showAlert(title: "Error", message: "Please enter a policy id.")
            return
        }
        guard let insurance = insurances.first(where: { $0.id == policyIdInt }) else {
            showAlert(title: "Error", message: "Please enter a valid policy id.")
            return
        }
        if insurance.claims.isEmpty {
            scrollView.isHidden = true
            noClaimsLabel.isHidden = false
            return
        }


        scrollView.isHidden = false
        noClaimsLabel.isHidden = true
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.setContentOffset(.zero, animated: false)
        
        var previousCard:ClaimCardView? = nil
        for claim in insurance.claims {
            let claimLabel = ClaimCardView(claim: claim,action: action)
            scrollView.addSubview(claimLabel)
            claimLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                claimLabel.topAnchor.constraint(equalTo:previousCard?.bottomAnchor ?? scrollView.topAnchor, constant: 2),
                claimLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                claimLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                claimLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                claimLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            previousCard = claimLabel
        }
        if let lastCard = previousCard {
            scrollView.bottomAnchor.constraint(equalTo: lastCard.bottomAnchor, constant: 16).isActive = true
        }
    }
    func action(claimId:Int,policyId:Int){
        let customClaimId = customClaim(claim_id: claimId, policy_id: policyId)
        self.performSegue(withIdentifier: "UpdateClaimScreen", sender: customClaimId)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateClaimScreen" {
            if let destinationVC = segue.destination as? UpdateClaimViewController {
                let claim = sender as! customClaim
                destinationVC.customClaim = claim
                }
            }
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
        policyIdPicker.resignFirstResponder()
        policyId.resignFirstResponder()
    }

}
class ClaimCardView: UIView {
    private let claim: Claim
    private let action: ((Int, Int) -> ())

    private let claimId = UILabel()
    private let policyId = UILabel()
    private let claimAmount = UILabel()
    private let dateOfClaim = UILabel()
    private let status = UILabel()

    init(claim: Claim, action: @escaping ((Int, Int) -> ())) {
        self.action = action
        self.claim = claim
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
        claimId.text = "Claim Id: \(claim.id)"
        policyId.text = "Policy Id: \(claim.policy_id)"
        claimAmount.text = "Claim Amount: \(claim.claim_amount)"
        dateOfClaim.text = "Date Of Claim: \(claim.date_of_claim)"
        status.text = "Status: \(claim.status)"
        
        claimId.font = UIFont.boldSystemFont(ofSize: 14)
        policyId.font = UIFont.boldSystemFont(ofSize: 14)
        claimAmount.font = UIFont.boldSystemFont(ofSize: 14)
        dateOfClaim.font = UIFont.boldSystemFont(ofSize: 14)
        status.font = UIFont.boldSystemFont(ofSize: 14)
    }

    @objc private func cardTapped() {
        action(claim.id, claim.policy_id)
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [claimId, policyId, claimAmount, dateOfClaim, status])
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


