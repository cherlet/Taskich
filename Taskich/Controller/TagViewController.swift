import UIKit

class TagViewController: UIViewController {
    // MARK: - Properties
    
    var tag: Tag?
    private let tagListViewController = TagListViewController()
    private let colorPickerView = ColorPickerView()
    
    var updateMode = false
    
    var onDismiss: (() -> Void)?
    var onTagAdded: ((String, String) -> Void)?
    var onTagUpdated: ((String, String) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .done
        return field
    }()
    
    private let firstSeparatorLine: UIView = {
        let view = UIScrollView()
        view.backgroundColor = .gray
        return view
    }()
    
    private let secondSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(UIColor.systemGreen, for: .normal)
        return button
    }()
    
    private let verticalSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        setupView()
        setupTagPickerView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .clear
        
        dimmedView.addGestureRecognizer(tapGestureRecognizer)
        cancelButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        [dimmedView, formView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            formView.widthAnchor.constraint(equalToConstant: 360),
            formView.heightAnchor.constraint(equalToConstant: 140),
            formView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupTagPickerView() {
        setupToUpdate(tag: tag)
        
        [firstSeparatorLine, textField, colorPickerView, secondSeparatorLine, verticalSeparatorLine, cancelButton, submitButton].forEach {
            formView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        textField.becomeFirstResponder()
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: formView.topAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            firstSeparatorLine.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            firstSeparatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            firstSeparatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            firstSeparatorLine.heightAnchor.constraint(equalToConstant: 0.8),
            
            colorPickerView.topAnchor.constraint(equalTo: firstSeparatorLine.bottomAnchor, constant: 4),
            colorPickerView.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            colorPickerView.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            colorPickerView.heightAnchor.constraint(equalToConstant: 36),
            
            secondSeparatorLine.topAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: 4),
            secondSeparatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            secondSeparatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            secondSeparatorLine.heightAnchor.constraint(equalToConstant: 0.8),
            
            verticalSeparatorLine.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            verticalSeparatorLine.topAnchor.constraint(equalTo: secondSeparatorLine.bottomAnchor),
            verticalSeparatorLine.bottomAnchor.constraint(equalTo: formView.bottomAnchor),
            verticalSeparatorLine.widthAnchor.constraint(equalToConstant: 0.8),
            
            cancelButton.centerYAnchor.constraint(equalTo: verticalSeparatorLine.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: verticalSeparatorLine.leadingAnchor),
            
            submitButton.centerYAnchor.constraint(equalTo: verticalSeparatorLine.centerYAnchor),
            submitButton.leadingAnchor.constraint(equalTo: verticalSeparatorLine.trailingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            
        ])
    }
    
    private func setupToUpdate(tag: Tag?) {
        guard let tag = tag else { return }
        
        self.textField.text = tag.name
        self.colorPickerView.selectColor(named: tag.color)
    }
    
    // MARK: - Other methods
    
    func appear(sender: UIViewController, tagToUpdate: Tag? = nil) {
        if let tag = tagToUpdate {
            self.tag = tag
            self.updateMode = true
        }
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = 0.6
            self.formView.alpha = 1
        }
    }
    
    @objc private func hide() {
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = 0
            self.formView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.onDismiss?()
            self.tag = nil
            self.updateMode = false
            self.removeFromParent()
        }
    }
    
    @objc func submit() {
        guard let text = textField.text,
              let color = colorPickerView.getSelectedColorName()
        else {
            hide()
            return
        }
        
        if updateMode {
            onTagUpdated?(text, color)
        } else {
            onTagAdded?(text, color)
        }
        
        hide()
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        return tapGesture
    }()
}

extension TagViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return true
    }
}
