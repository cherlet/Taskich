import UIKit

class DatePickerViewController: UIViewController {
    
    private let datePickerView = DatePickerView()
    var onDismiss: (() -> Void)?
    
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
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(UIColor.systemGreen, for: .normal)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private let verticalSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    var onDateSelected: ((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDatePickerView()
    }
    
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
            formView.heightAnchor.constraint(equalToConstant: 400),
            formView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupDatePickerView() {
        [datePickerView, separatorLine, verticalSeparatorLine, cancelButton, submitButton].forEach {
            formView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            datePickerView.topAnchor.constraint(equalTo: formView.topAnchor),
            datePickerView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            datePickerView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            datePickerView.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -45),
            
            separatorLine.topAnchor.constraint(equalTo: datePickerView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            verticalSeparatorLine.centerXAnchor.constraint(equalTo: formView.centerXAnchor),
            verticalSeparatorLine.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            verticalSeparatorLine.bottomAnchor.constraint(equalTo: formView.bottomAnchor),
            verticalSeparatorLine.widthAnchor.constraint(equalToConstant: 1),
            
            cancelButton.centerYAnchor.constraint(equalTo: verticalSeparatorLine.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: verticalSeparatorLine.leadingAnchor),
            
            submitButton.centerYAnchor.constraint(equalTo: verticalSeparatorLine.centerYAnchor),
            submitButton.leadingAnchor.constraint(equalTo: verticalSeparatorLine.trailingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            
        ])
    }
    
    func appear(sender: UIViewController) {
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
            self.removeFromParent()
        }
    }
    
    @objc func get() -> Date {
        let date = datePickerView.getDate()
        return date
    }
    
    @objc func submit() {
        let date = datePickerView.getDate()
        onDateSelected?(date)
        hide()
    }
    
    func setDateView(_ date: Date?) {
        datePickerView.setDate(date)
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        return tapGesture
    }()
}


