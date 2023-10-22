import UIKit

class TaskPresenterViewController: UIViewController {
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
    
    // MARK: - Model properties
    let textField = UITextField()
    var taskText: String?
    var onTaskTextUpdate: ((String) -> Void)?
    
    // MARK: - Life Cycle
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
    
    func setupForm() {
        view.backgroundColor = .clear
        dimmedView.addGestureRecognizer(tapGestureRecognizer)
        
        textField.text = taskText
        textField.returnKeyType = .done
        textField.delegate = self
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16)
        ])
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
extension TaskPresenterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let taskText = textField.text, !taskText.isEmpty {
            onTaskTextUpdate?(taskText)
            animateDismissView()
        }
        return true
    }
}

