import UIKit

class ViewInsuranceViewController: UIViewController {
    
    @IBOutlet var noInsuranceLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
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
        if insurances.isEmpty {
            noInsuranceLabel.isHidden = false
            scrollView.isHidden = true
        } else {
            noInsuranceLabel.isHidden = true
            var previousCard: UIView? = nil
            scrollView.subviews.forEach { $0.removeFromSuperview() }
            scrollView.setContentOffset(.zero, animated: false)
            for insurance in insurances {
                let cardView = InsuranceCardView(insurance: insurance, action: cardTapped)
                scrollView.addSubview(cardView)
                cardView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    cardView.topAnchor.constraint(equalTo:previousCard?.bottomAnchor ?? scrollView.topAnchor, constant: 2),
                    cardView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    cardView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    cardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                ])
                previousCard = cardView
            }
            
            if let lastCard = previousCard {
                scrollView.bottomAnchor.constraint(equalTo: lastCard.bottomAnchor, constant: 16).isActive = true
            }
        }
    }
    
    @objc func cardTapped(_ insuranceId: Int) {
        let insurance = InsuranceDirectory.shared.getInsurance(id: insuranceId)
        self.performSegue(withIdentifier: "UpdateInsuranceScreen", sender: insurance)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateInsuranceScreen" {
            if let destinationVC = segue.destination as? UpdateInsuranceViewController {
                let insurance = sender as! Insurance
                destinationVC.insurance = insurance
                }
            }
    }
}
class InsuranceCardView: UIView {
    private let policyTypeLabel = UILabel()
    private let premiumLabel = UILabel()
    private let customerIdLabel = UILabel()
    private let startDateLabel = UILabel()
    private let endDateLabel = UILabel()
    private let insuranceId:Int
    private var action:((Int)->())
    
    init(insurance: Insurance, action: @escaping ((Int)->())) {
        self.action = action
        self.insuranceId = insurance.id
        super.init(frame: .zero)
        policyTypeLabel.text = "Policy Type: \(insurance.policy_type)"
        premiumLabel.text = "Premium: \(insurance.premium_amount)"
        customerIdLabel.text = "Customer ID: \(insurance.customer_id)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Customize the date format as needed
        startDateLabel.text = "Start Date: \(dateFormatter.string(from: insurance.start_date))"
        endDateLabel.text = "End Date: \(dateFormatter.string(from: insurance.end_date))"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func cardTapped() {
        action(insuranceId)
    }
    
    private func setupUI() {
        
        policyTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        premiumLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        customerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [policyTypeLabel, premiumLabel, startDateLabel, endDateLabel])
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
