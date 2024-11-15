import UIKit

class FriendMessageCell: UITableViewCell {
    private let messageContainer = UIView()
    private let textContainer = UIView()
    let messageLabel = UILabel()
    let senderLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        contentView.addSubview(messageContainer)
        
        textContainer.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        textContainer.layer.cornerRadius = 10
        textContainer.clipsToBounds = true
        messageContainer.addSubview(textContainer)

        messageLabel.numberOfLines = 0
        messageLabel.textColor = .black
        textContainer.addSubview(messageLabel)
        
        senderLabel.textColor = .darkGray
        messageContainer.addSubview(senderLabel)
        
        timeLabel.textColor = .gray
        timeLabel.font = UIFont.systemFont(ofSize: 8) // Smaller font size
        messageContainer.addSubview(timeLabel)
    }

//    private func setupConstraints() {
//        messageContainer.translatesAutoresizingMaskIntoConstraints = false
//        senderLabel.translatesAutoresizingMaskIntoConstraints = false
//        textContainer.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        timeLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            // Container constraints within the cell
//            messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            messageContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor),
//            
//            // Message label padding inside the container
//            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 12),
//            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
//            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -12),
//            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -8)
//        ])
//    }
    
    private func setupConstraints() {
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container constraints within the cell
            messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor),

            // Sender label constraints
            senderLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            senderLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
            senderLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageContainer.trailingAnchor, constant: -16),

            // Text container constraints
            textContainer.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            textContainer.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -16),
            textContainer.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),

            // Message label constraints
            messageLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -8),

            // Time label constraints
            timeLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageContainer.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: messageContainer.bottomAnchor, constant: -8),
        ])
    }

    func configure(_ message: Message, _ contactName: String) {
        senderLabel.text = contactName
        messageLabel.text = message.text
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        timeLabel.text = formatter.string(from: message.timestamp)
    }
}
