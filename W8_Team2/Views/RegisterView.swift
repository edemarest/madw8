import UIKit

protocol RegisterViewDelegate: AnyObject {
    func didTapRegisterButton(name: String, email: String, password: String)
    func didTapBackButton()
}

class RegisterView: UIViewController {

    // UI Elements
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let confirmPasswordTextField = UITextField()
    let registerButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)

    // Delegate
    weak var delegate: RegisterViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
        setupConstraints()
    }

    private func setupUIElements() {
        view.backgroundColor = .white
        
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        view.addSubview(backButton)

        nameTextField.placeholder = "Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocapitalizationType = .words
        view.addSubview(nameTextField)

        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        view.addSubview(emailTextField)

        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)

        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        view.addSubview(confirmPasswordTextField)

        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 25
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        view.addSubview(registerButton)
    }

    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            nameTextField.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTapBack() {
        delegate?.didTapBackButton()
    }

    @objc private func registerButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }

        delegate?.didTapRegisterButton(name: name, email: email, password: password)
    }

    private func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
