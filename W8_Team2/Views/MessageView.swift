import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageView: UIView, UITableViewDelegate, UITableViewDataSource {
    // UI Elements
    let contactNameLabel = UILabel()
    let closeButton = UIButton(type: .system)
    let tableView = UITableView()
    let messageInputView = UIView()
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    
    // Properties
    var messages: [Message] = []
    var currentUserId: String?
    var chatId: String?
    var contactName: String? {
        didSet {
            contactNameLabel.text = contactName
        }
    }
    var refreshContactsCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupTableView()
        observeMessages()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupTableView()
        observeMessages()
    }

    private func setupUIElements() {
        backgroundColor = .white
        
        // Set up Contact Name Label
        contactNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contactNameLabel.textAlignment = .center
        addSubview(contactNameLabel)
        
        // Set up Close Button
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        addSubview(closeButton)
        
        // Set up TableView
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "OwnMessageCell")
        tableView.register(FriendMessageCell.self, forCellReuseIdentifier: "FriendMessageCell")
        tableView.separatorStyle = .none
        addSubview(tableView)
        
        // Set up message input area
        messageInputView.backgroundColor = .white
        messageInputView.layer.borderColor = UIColor.lightGray.cgColor
        messageInputView.layer.borderWidth = 1.0
        addSubview(messageInputView)
        
        messageTextField.placeholder = "Enter message..."
        messageTextField.borderStyle = .roundedRect
        messageInputView.addSubview(messageTextField)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        messageInputView.addSubview(sendButton)
    }

    private func setupConstraints() {
        contactNameLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Contact Name Label at the top
            contactNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            contactNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Close Button aligned to the left of the Contact Name Label
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: contactNameLabel.centerYAnchor),
            
            // TableView constraints, placed below the contact name and close button
            tableView.topAnchor.constraint(equalTo: contactNameLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            // Message Input View constraints
            messageInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 50),
            
            // Message TextField constraints with padding
            messageTextField.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 8),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 36),

            // Send Button constraints
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - TableView Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.senderId == currentUserId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OwnMessageCell", for: indexPath) as! OwnMessageCell
            guard let contactName = contactName else {
                return cell
            }
            cell.configure(message, contactName)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendMessageCell", for: indexPath) as! FriendMessageCell
            guard let contactName = contactName else {
                return cell
            }
            cell.configure(message, contactName)
            return cell
        }
    }

    // MARK: - Send Message Action
    
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.isEmpty, let chatId = chatId else { return }
        sendMessage(text: text, chatId: chatId)
        messageTextField.text = ""
    }

    private func sendMessage(text: String, chatId: String) {
        let db = Firestore.firestore()
        let messageData: [String: Any] = [
            "senderId": currentUserId ?? "",
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("chats").document(chatId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }

    // MARK: - Observe Messages
    
    func observeMessages() {
        guard let chatId = chatId else { return }
        
        let db = Firestore.firestore()
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error observing messages: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.messages = documents.compactMap { Message(data: $0.data()) }
                self?.tableView.reloadData()
                
                // Scroll to the bottom
                if let messageCount = self?.messages.count, messageCount > 0 {
                    let lastIndex = IndexPath(row: messageCount - 1, section: 0)
                    self?.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
                }
            }
    }
    
    @objc private func closeButtonTapped() {
        refreshContactsCallback?()
        self.removeFromSuperview()
    }
}
