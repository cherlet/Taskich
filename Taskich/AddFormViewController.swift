import UIKit

class AddFormViewController: UIViewController {
    
    // MARK: - View Properties
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = dimmedAlpha
        return view
    }()
    
    private let defaultHeight: CGFloat = 500
    private let dimmedAlpha: CGFloat = 0.6
    private var formViewHeightConstraint: NSLayoutConstraint?
    private var formViewBottomConstraint: NSLayoutConstraint?

    let textField = UITextField()
    let addButton = UIButton()
    let dateButton = UIButton()
    let datePickerViewController = DatePickerViewController()
    var onAddButtonTapped: ((String, Date) -> Void)?
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateDimmedView()
    }
    
    // MARK: - Setup methods
    private func setupConstraints() {
        [dimmedView, formView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        formViewHeightConstraint = formView.heightAnchor.constraint(equalToConstant: defaultHeight)
        formViewBottomConstraint = formView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
        formViewHeightConstraint?.isActive = true
        formViewBottomConstraint?.isActive = true
    }
    
    private func setupForm() {
        view.backgroundColor = .clear
        dimmedView.addGestureRecognizer(tapGestureRecognizer)
        
        textField.placeholder = "Задача"
        textField.returnKeyType = .done
        textField.delegate = self
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 24)
        addButton.setImage(UIImage(systemName: "arrow.up.circle", withConfiguration: configuration), for: .normal)
        dateButton.setImage(UIImage(systemName: "calendar", withConfiguration: configuration), for: .normal)
        
        [addButton, dateButton].forEach {
            $0.imageView?.contentMode = .scaleAspectFit
            $0.tintColor = .black
        }
        
        [textField, addButton, dateButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
    
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            
            dateButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            dateButton.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Button action methods
    @objc private func addButtonTapped() {
        let date = datePickerViewController.submit()
        
        if let taskText = textField.text {
            onAddButtonTapped?(taskText, date)
        }
        
        animateDismissView()
    }
    
    @objc private func dateButtonTapped() {
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.appear(sender: self)
    }
    
    // MARK: - Animate methods
    private func animatePresentForm() {
        UIView.animate(withDuration: 0.15) {
            self.formViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0) {
            self.dimmedView.alpha = self.dimmedAlpha
        } completion: { _ in
            self.textField.becomeFirstResponder()
            self.animatePresentForm()
        }
    }
    
    @objc private func animateDismissView() {
        dimmedView.alpha = dimmedAlpha
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        
        UIView.animate(withDuration: 0.15) {
            self.textField.resignFirstResponder()
            self.formViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MARK: - Gesture methods
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        return tapGesture
    }()
}

// MARK: - Extensions

extension AddFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let date = datePickerViewController.submit()
        
        if let taskText = textField.text, !taskText.isEmpty {
            onAddButtonTapped?(taskText, date)
            animateDismissView()
        }
        return true
    }
}

