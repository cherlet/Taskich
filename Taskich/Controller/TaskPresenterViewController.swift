import UIKit

class TaskPresenterViewController: UIViewController {
    
    // MARK: - Properties
    let datePickerViewController = DatePickerViewController()
    var onTaskTextUpdate: ((String, Date) -> Void)?
    
    var taskText: String?
    var taskDate: Date? {
        didSet {
            updateDateLabel()
        }
    }
    
    //MARK: - UI Components
    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.returnKeyType = .done
        return tv
    }()
    
    let dateView = TaskPresenterFieldView(text: "", image: "calendar")
    let reminderView = TaskPresenterFieldView(text: "Добавить напоминание", image: "bell")
    let repeaterView = TaskPresenterFieldView(text: "Сделать регулярной", image: "arrow.counterclockwise")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        if let taskText = textView.text, !taskText.isEmpty {
            onTaskTextUpdate?(taskText, taskDate ?? Date())
        }
    }
    
    // MARK: - Setup methods
    func setupView() {
        view.backgroundColor = .white
        
        dateView.addGestureRecognizer(dateTapGestureRecognizer)
        updateDateLabel()

        textView.delegate = self
        textView.text = taskText

        [textView, dateView, reminderView, repeaterView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            dateView.heightAnchor.constraint(equalToConstant: 32),
            dateView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            dateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            reminderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            reminderView.heightAnchor.constraint(equalToConstant: 32),
            reminderView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 12),
            reminderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reminderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            repeaterView.widthAnchor.constraint(equalTo: view.widthAnchor),
            repeaterView.heightAnchor.constraint(equalToConstant: 32),
            repeaterView.topAnchor.constraint(equalTo: reminderView.bottomAnchor, constant: 12),
            repeaterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            repeaterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
        
    // MARK: - Gesture methods
    private lazy var dateTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateButtonTapped))
        return tapGesture
    }()
    
    // MARK: - Action methods
    @objc private func dateButtonTapped() {
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.appear(sender: self)
        datePickerViewController.onDateSelected = { selectedDate in
            self.taskDate = selectedDate
        }
    }
    
    // MARK: - Helper methods
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
    
    private func updateDateLabel() {
        dateView.updateDateLabel(text: formattedDate(from: taskDate ?? Date()))
        datePickerViewController.setDateView(taskDate)
    }
}

// MARK: - TextView Delegate
extension TaskPresenterViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let taskText = textView.text, !taskText.isEmpty {
            onTaskTextUpdate?(taskText, taskDate ?? Date())
            dismiss(animated: true)
        }
    }
}


