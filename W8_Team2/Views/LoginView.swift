import UIKit

protocol LoginViewDelegate: AnyObject {
    func didTapRegisterButton()
    func didTapLoginButton(email: String, password: String)
}

class LoginView: UIView {

    // UI Elements
    let titleLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .system)
    let promptLabel = UILabel()
    let registerButton = UIButton(type: .system)

    weak var delegate: LoginViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    private func setupUIElements() {
        backgroundColor = .white

        // Title Label
        titleLabel.text = "Log in to start messaging!"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailTextField.leftViewMode = .always
        addSubview(emailTextField)

        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordTextField.leftViewMode = .always
        addSubview(passwordTextField)

        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 25
        loginButton.clipsToBounds = true
        addSubview(loginButton)

        // Prompt Label
        promptLabel.text = "Don't have an account? Make one!"
        promptLabel.font = UIFont.systemFont(ofSize: 14)
        promptLabel.textAlignment = .center
        addSubview(promptLabel)

        // Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 25
        registerButton.clipsToBounds = true
        addSubview(registerButton)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            // Register Button & Prompt Label aligned to the bottom
            registerButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 50),

            promptLabel.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -10),
            promptLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            promptLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    @objc private func didTapLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Please fill in both fields")
            return
        }

        delegate?.didTapLoginButton(email: email, password: password)
    }

    @objc private func didTapRegister() {
        delegate?.didTapRegisterButton()
    }
}
