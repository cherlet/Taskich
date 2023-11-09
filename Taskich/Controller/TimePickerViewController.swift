import UIKit

class TimePickerViewController: UIViewController {

    var onTimeSelected: ((Date) -> Void)?
    
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
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

    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appGray
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.appAccent, for: .normal)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.appGray, for: .normal)
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()
    
    private let verticalSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTimePicker()
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
    
    private func setupTimePicker() {
        [timePicker, separatorLine, verticalSeparatorLine, cancelButton, submitButton, dateLabel].forEach {
            formView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: formView.topAnchor),
            timePicker.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            timePicker.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -81),
            
            dateLabel.topAnchor.constraint(equalTo: timePicker.bottomAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
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
    
    func appear(sender: UIViewController, with date: Date) {
        sender.present(self, animated: false) {
            self.show()
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        if let newDate = calendar.date(from: components) {
            timePicker.date = newDate
        } else {
            timePicker.date = date
        }
        
        dateLabel.text = formattedDate(from: timePicker.date)
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
            self.removeFromParent()
        }
    }
    
    @objc func submit() {
        let date = self.timePicker.date
        self.onTimeSelected?(date)
        hide()
    }

    @objc func dismissPicker() {
        onTimeSelected?(timePicker.date)
        dismiss(animated: true)
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        return tapGesture
    }()
    
    private func formattedDate(from date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let yearOfGivenDate = calendar.component(.year, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        if yearOfGivenDate > currentYear {
            dateFormatter.dateFormat = "d MMMM yyyy"
        } else {
            dateFormatter.dateFormat = "d MMMM"
        }
        
        return dateFormatter.string(from: date)
    }
}

