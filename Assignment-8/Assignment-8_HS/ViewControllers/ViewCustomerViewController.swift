import UIKit

class ViewCustomerViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var noCustomersLabel: UILabel!
    
    private var customerList: [Customer] = InsuranceDirectory.shared.getCustomers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Customer")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customerList = InsuranceDirectory.shared.getCustomers()
        setupUI()
    }
    func setupUI(){
        if customerList.isEmpty {
            scrollView.isHidden = true
        } else {
            noCustomersLabel.isHidden = true
            scrollView.subviews.forEach { $0.removeFromSuperview() }
            scrollView.setContentOffset(.zero, animated: false)
            var previousCard: UIView? = nil
            for costumer in customerList {
                let cardView = CustomerCardView(user: costumer,action: cardTapped)
                scrollView.addSubview(cardView)
                cardView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    cardView.topAnchor.constraint(equalTo:previousCard?.bottomAnchor ?? scrollView.topAnchor, constant: 2),
                    cardView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    cardView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    cardView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                    cardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                ])
                
                previousCard = cardView
            }
            
            // Set content size of the scroll view
            if let lastCard = previousCard {
                scrollView.bottomAnchor.constraint(equalTo: lastCard.bottomAnchor, constant: 16).isActive = true
            }
            
        }
    }
    func cardTapped(id:Int) {
        let user = InsuranceDirectory.shared.getCustomer(id: id)
        self.performSegue(withIdentifier: "updateCustomerScreen", sender: user)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateCustomerScreen" {
                if let destinationVC = segue.destination as? UpdateCustomerViewController {
                    let user = sender as! Customer
                    destinationVC.user = user
                }
            }
    }
}


class CustomerCardView:UIView{
    private var userId: Int
    private let idLabel = UILabel()
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()
    private let emailLabel = UILabel()
    private let action: ((Int) -> ())
    
    
    init(user: Customer, action:@escaping ((Int)->())) {
        self.userId = user.id
        self.action = action
        super.init(frame: .zero)
        idLabel.text = "ID: \(user.id)"
        nameLabel.text = "Name: \(user.name)"
        ageLabel.text = "Age: \(user.age)"
        emailLabel.text = "Email: \(user.email)"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func cardTapped() {
        action(userId)
    }
    private func setupUI(){
        addSubview(idLabel)
        addSubview(nameLabel)
        addSubview(ageLabel)
        addSubview(emailLabel)
        
        idLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        ageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        emailLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [idLabel, nameLabel, ageLabel, emailLabel])
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

