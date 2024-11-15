import UIKit

class ContactCell: UITableViewCell {

    let nameLabel = UILabel()
    let lastMessageLabel = UILabel()
    let lastMessageDateLabel = UILabel()
    let messageButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
    }

    private func setupUIElements() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        contentView.addSubview(nameLabel)

        lastMessageLabel.font = UIFont.systemFont(ofSize: 14)
        lastMessageLabel.textColor = .gray
        lastMessageLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        contentView.addSubview(lastMessageLabel)

        lastMessageDateLabel.font = UIFont.systemFont(ofSize: 12)
        lastMessageDateLabel.textColor = .gray
        contentView.addSubview(lastMessageDateLabel)

        messageButton.setTitle("💬", for: .normal)
        contentView.addSubview(messageButton)
    }

    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageDateLabel.translatesAutoresizingMaskIntoConstraints = false
        messageButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageButton.leadingAnchor, constant: -8),

            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            lastMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            lastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageButton.leadingAnchor, constant: -8),

            lastMessageDateLabel.trailingAnchor.constraint(equalTo: messageButton.leadingAnchor, constant: -8),
            lastMessageDateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            messageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        lastMessageLabel.text = contact.lastMessage ?? "No messages yet"
        if let lastMessageDate = contact.lastMessageDate {
            lastMessageDateLabel.text = DateFormatter.localizedString(from: lastMessageDate, dateStyle: .short, timeStyle: .short)
        } else {
            lastMessageDateLabel.text = ""
        }
    }
}
