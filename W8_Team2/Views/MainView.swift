import UIKit

protocol MainViewDelegate: AnyObject {
    func didTapLogoutButton()
    func didTapContact(for contact: Contact)
}

class MainView: UIView, UITableViewDelegate, UITableViewDataSource {
    let logoutButton = UIButton(type: .system)
    let tableView = UITableView()
    weak var delegate: MainViewDelegate?
    var contacts: [Contact] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupTableView()
    }

    private func setupUIElements() {
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        addSubview(logoutButton)

        tableView.register(ContactCell.self, forCellReuseIdentifier: "contactCell")
        addSubview(tableView)
    }

    private func setupConstraints() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            logoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactCell else {
            return UITableViewCell()
        }
        
        let contact = contacts[indexPath.row]
        cell.configure(with: contact)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let contact = contacts[indexPath.row]
         print("Contact cell tapped for: \(contact.name)")
         delegate?.didTapContact(for: contact)
         tableView.deselectRow(at: indexPath, animated: true)
     }

    func updateContacts(_ newContacts: [Contact]) {
        self.contacts = newContacts
        tableView.reloadData()
    }
    
    @objc private func logoutButtonTapped() {
        delegate?.didTapLogoutButton()
    }
}
