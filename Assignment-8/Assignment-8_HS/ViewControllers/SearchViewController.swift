import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchResults: UIButton!
    @IBOutlet var noResults: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    private var searchKeyword:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        
        let action1 = UIAction(title: "Insurance ID") { action in
            self.searchResults?.setTitle("Insurance ID", for: .normal)
            self.searchKeyword = "Insurance"
        }
        let action2 = UIAction(title: "Claim ID") { action in
            self.searchResults?.setTitle("Claim ID", for: .normal)
            self.searchKeyword = "Claims"
        }
        let action3 = UIAction(title: "Customer Name") { action in
            self.searchResults?.setTitle("Customer Name", for: .normal)
            self.searchKeyword = "Customers"
        }
        
        let menu = UIMenu(children: [action1, action2, action3])
        searchResults?.menu = menu
        searchResults?.showsMenuAsPrimaryAction = true
        
        scrollView?.isHidden = true
        
        
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        guard searchKeyword != nil else {
            showAlert(title: "Error", message: "Search keyword not found")
            return
        }

        
        
        
        switch searchKeyword {
            case "Insurance":
                fillScrollViewInsurance()
            case "Claims":
                fillScrollViewClaims()
            case "Customers":
                fillScrollViewCustomers()
            default:  // Correct default case syntax
                showAlert(title: "Error", message: "No results found!")
        }
    }
    
    func fillScrollViewClaims() {
        var claimList: [Claim] = InsuranceDirectory.shared.getClaims().filter{c in
            String(c.id).hasPrefix(searchBar.text!)}
        if claimList.isEmpty {
            showAlert(title: "Warning", message: "No result found")
            claimList = InsuranceDirectory.shared.getClaims()
        }
        print("Claim list count: \(claimList.count)")
        if claimList.isEmpty {
            noResults.isHidden = false
        } else {
            noResults.isHidden = true
            scrollView.isHidden = false
            reset()
            var previousCard:ClaimCardView? = nil
            for claim in claimList {
                let claimLabel = ClaimCardView(claim: claim,action: {_, __ in})
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
        
        
        
    }
    func fillScrollViewCustomers() {
        var customerList: [Customer] = InsuranceDirectory.shared.getCustomers().filter{$0.name.localizedCaseInsensitiveContains(searchBar.text!)}
        if customerList.isEmpty {
            showAlert(title: "Warning", message: "No result found")
            customerList = InsuranceDirectory.shared.getCustomers()
        }
        
        print("Customer list count: \(customerList.count)")
        if customerList.isEmpty {
            noResults.isHidden = false
        } else {
            noResults.isHidden = true
            scrollView.isHidden = false
            reset()
            var previousCard: CustomerCardView? = nil
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
    
    func fillScrollViewInsurance() {
        noResults?.isHidden = true
        scrollView?.isHidden = false
        var insurances: [Insurance] = InsuranceDirectory.shared.getInsurances().filter({c in
            String(c.id).hasPrefix(searchBar.text!)
        })
        
        if insurances.isEmpty {
            showAlert(title: "Warning", message: "No result found")
            insurances = InsuranceDirectory.shared.getInsurances()
        }
        reset()
        var previousCard: UIView? = nil
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
    
    func reset(){
        scrollView?.subviews.forEach { $0.removeFromSuperview() }
        scrollView?.setContentOffset(.zero, animated: false)
    }
    func cardTapped(id:Int) {
       
    }
    
    
    func showAlert(title: String, message: String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
}

