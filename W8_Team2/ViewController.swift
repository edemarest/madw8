import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import UIKit

// Assignment 8: Updated to latest XCode and min deployment 16.7
//Notes:
// Add group chats (?)
// Make sure contacts dont switch order when fetching/re-fetching
class ViewController: UIViewController, LoginViewDelegate, RegisterViewDelegate, MainViewDelegate {

    var currentUser: User?
    var contacts: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure Firebase is initialized before proceeding
        if FirebaseApp.app() == nil {
            print("Configuring Firebase...")
            FirebaseApp.configure()
        } else {
            print("Firebase is already configured.")
        }
        
        // Check for authenticated user
        if let user = Auth.auth().currentUser {
            print("User is authenticated with ID: \(user.uid)")
            currentUser = user
            fetchContacts()
        } else {
            print("User not authenticated. Showing login view.")
            showLoginView()
        }
    }


    // MARK: - LoginViewDelegate Methods

    func didTapRegisterButton() {
        let registerView = RegisterView()
        registerView.delegate = self
        registerView.modalPresentationStyle = .fullScreen
        present(registerView, animated: true, completion: nil)
    }
    
    func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    func didTapLoginButton(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(title: "Login Error", message: error.localizedDescription)
                return
            }
            // Clear contacts on successful login to ensure only new user's contacts are shown
            self?.contacts.removeAll()
            self?.showMainView()
            self?.fetchContacts()
        }
    }
    
    func didTapContact(for contact: Contact) {
        print("Attempting to show MessageView for contact: \(contact.name)")
        
        let messageView = MessageView(frame: view.bounds)
        messageView.currentUserId = Auth.auth().currentUser?.uid
        messageView.contactName = contact.name

        if let currentUserId = messageView.currentUserId, !currentUserId.isEmpty,
           !contact.id.isEmpty {
            messageView.chatId = [currentUserId, contact.id].sorted().joined()
            messageView.observeMessages()
            print("Displaying MessageView with chat ID: \(messageView.chatId ?? "No chat ID")")
        } else {
            print("Error: Missing user ID or contact ID.")
            return
        }

        // Set up callback to refresh contacts on close
        messageView.refreshContactsCallback = { [weak self] in
            print("Refreshing contacts before returning to MainView")
            self?.fetchContacts()
        }

        // Present MessageView
        messageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: view.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }


    // MARK: - RegisterViewDelegate Methods
    func didTapRegisterButton(name: String, email: String, password: String) {
        print("Attempting to register")
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(title: "Registration Error", message: error.localizedDescription)
                return
            }
            
            if let uid = authResult?.user.uid {
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "name": name,
                    "email": email
                ]) { [weak self] error in
                    if let error = error {
                        print("Error saving user data: \(error)")
                        self?.showAlert(title: "Database Error", message: error.localizedDescription)
                    } else {
                        print("User successfully registered. Fetching contacts...")
                        // Fetch contacts after registering
                        self?.fetchContacts()
                        self?.dismiss(animated: true) {
                            self?.showMainView()
                        }
                    }
                }
            }
        }
    }

    // MARK: - MainViewDelegate Methods
    func didTapLogoutButton() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            contacts.removeAll()
            showLoginView()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showAlert(title: "Logout Error", message: signOutError.localizedDescription)
        }
    }

    private func fetchContacts() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No current user ID.")
            return
        }

        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching contacts: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            print("Fetched contacts snapshot: \(documents.count) documents.")
            self?.contacts.removeAll()
            var processedCount = 0
            
            for document in documents {
                let data = document.data()
                let userId = document.documentID
                
                if userId == currentUserId {
                    processedCount += 1
                    continue
                }
                
                if let name = data["name"] as? String,
                   let email = data["email"] as? String {
                    self?.fetchLastMessage(with: userId) { lastMessage, lastMessageDate in
                        let contact = Contact(id: userId, name: name, email: email, lastMessage: lastMessage, lastMessageDate: lastMessageDate)
                        self?.contacts.append(contact)
                        processedCount += 1
                        
                        // Sort contacts alphabetically by name
                        if processedCount == documents.count {
                            self?.contacts.sort { $0.name < $1.name }
                            self?.showMainView()
                        }
                    }
                } else {
                    processedCount += 1
                }
            }
        }
    }

    private func fetchLastMessage(with userId: String, completion: @escaping (String?, Date?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let chatId = [currentUserId, userId].sorted().joined()

        db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching last message: \(error)")
                    completion(nil, nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(nil, nil)
                    return
                }
                
                let data = document.data()
                print("printing message. . .")
                print(data)
                let lastMessage = data["text"] as? String
                let lastMessageDate = (data["timestamp"] as? Timestamp)?.dateValue()
                
                completion(lastMessage, lastMessageDate)
            }
    }

    private func showMainView() {
        print("showMainView() is called")
        let mainView = MainView(frame: view.bounds)
        mainView.delegate = self
        mainView.updateContacts(contacts)
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(mainView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func showLoginView() {
        let loginView = LoginView(frame: view.bounds)
        loginView.delegate = self
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(loginView)
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
