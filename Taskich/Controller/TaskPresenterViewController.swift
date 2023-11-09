import UIKit

class TaskPresenterViewController: UIViewController {
    
    // MARK: - Properties
    let datePickerViewController = DatePickerViewController()
    let timePickerViewController = TimePickerViewController()
    var onTaskTextUpdate: ((String, Date, Date?, Tag) -> Void)?
    
    var taskText: String?
    var taskDate: Date?
    var taskReminder: Date?
    
    var tag: Tag?
    
    //MARK: - UI Components
    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.returnKeyType = .done
        tv.backgroundColor = .appBackground
        return tv
    }()
    
    private lazy var tagView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: tag?.color ?? "")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = tag?.name
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let dateView = TaskPresenterFieldView(text: "", image: "calendar")
    let reminderView = TaskPresenterFieldView(text: "Добавить напоминание", image: "bell")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        if let taskText = textView.text, !taskText.isEmpty, let tagLabel = tag {
            onTaskTextUpdate?(taskText, taskDate ?? Date(), taskReminder, tagLabel)
        }
    }
    
    // MARK: - Setup methods
    func setupView() {
        view.backgroundColor = .appBackground
        
        tagView.addGestureRecognizer(tagTapGestureRecognizer)
        dateView.addGestureRecognizer(dateTapGestureRecognizer)
        reminderView.addGestureRecognizer(reminderTapGestureRecognizer)
        reminderView.deleteButton.addTarget(self, action: #selector(reminderDeleteButtonTapped), for: .touchUpInside)
        
        updateDateLabel()
        updateReminderLabel()

        textView.delegate = self
        textView.text = taskText
        
        tagView.addSubview(tagLabel)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false

        [textView, tagView, dateView, reminderView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tagView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 24),
            tagView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tagView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5),
            
            tagLabel.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -12),
            tagLabel.topAnchor.constraint(equalTo: tagView.topAnchor, constant: 4),
            tagLabel.bottomAnchor.constraint(equalTo: tagView.bottomAnchor, constant: -4),
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),

            dateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            dateView.heightAnchor.constraint(equalToConstant: 32),
            dateView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 16),
            dateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            reminderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            reminderView.heightAnchor.constraint(equalToConstant: 32),
            reminderView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 12),
            reminderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reminderView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
        
    // MARK: - Gesture methods
    private lazy var dateTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateViewTapped))
        return tapGesture
    }()
    
    private lazy var reminderTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderViewTapped))
        return tapGesture
    }()
    
    private lazy var tagTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tagViewTapped))
        return tapGesture
    }()
    
    // MARK: - Action methods
    @objc private func dateViewTapped() {
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.appear(sender: self)
        datePickerViewController.onDateSelected = { [weak self] selectedDate in
            self?.taskDate = selectedDate
            self?.updateDateLabel()
        }
    }
    
    @objc private func reminderViewTapped() {
        NotificationManager.shared.requestNotificationAuthorizationIfNeeded()
        timePickerViewController.modalPresentationStyle = .overFullScreen
        timePickerViewController.appear(sender: self, with: taskDate ?? Date())
        timePickerViewController.onTimeSelected = { [weak self] selectedTime in
            self?.taskReminder = selectedTime
            self?.updateReminderLabel()
        }
    }
    
    @objc private func reminderDeleteButtonTapped() {
        reminderView.deleteReminderLabel()
        self.taskReminder = nil
    }
    
    @objc private func tagViewTapped() {
        let tagListViewController = TagListViewController()
        tagListViewController.modalPresentationStyle = .overFullScreen
        tagListViewController.appear(sender: self)
        tagListViewController.tagSelected = { [weak self] tag in
            self?.tag = tag
            self?.updateTagView()
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
    
    private func formattedTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    private func updateDateLabel() {
        dateView.updateDateLabel(text: formattedDate(from: taskDate ?? Date()))
        datePickerViewController.setDateView(taskDate)
    }
    
    private func updateReminderLabel() {
        guard let reminder = taskReminder else { return }
        reminderView.updateReminderLabel(formattedTime(from: reminder))
    }
    
    private func updateTagView() {
        tagView.backgroundColor = UIColor(named: tag?.color ?? "")
        tagLabel.textColor = .white
        tagLabel.text = tag?.name
        tagView.layoutIfNeeded()
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
            onTaskTextUpdate?(taskText, taskDate ?? Date(), taskReminder, tag!)
            dismiss(animated: true)
        }
    }
}


