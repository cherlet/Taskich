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
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.returnKeyType = .done
        return tv
    }()
    var taskText: String?
    var taskDate: Date? {
        didSet {
            updateDateLabel()
        }
    }
    let dateView = UIView()
    let dateImage = UIImageView(image: UIImage(systemName: "calendar"))
    let dateLabel = UILabel()
    let datePickerViewController = DatePickerViewController()
    var onTaskTextUpdate: ((String, Date) -> Void)?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupFields()
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
    
    func setupFields() {
        dateView.backgroundColor = .clear
        dateImage.tintColor = .black
        dateLabel.text = formattedDate(from: taskDate ?? Date())
        
        [dateImage, dateLabel].forEach {
            dateView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dateImage.leadingAnchor.constraint(equalTo: dateView.leadingAnchor, constant: 16),
            dateImage.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateImage.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor)
        ])
    }
    
    func setupForm() {
        view.backgroundColor = .clear
        dimmedView.addGestureRecognizer(dismissGestureRecognizer)
        dateView.addGestureRecognizer(dateTapGestureRecognizer)
        
        textView.delegate = self
        textView.text = taskText
        
        [textView, dateView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            
            dateView.widthAnchor.constraint(equalTo: formView.widthAnchor),
            dateView.heightAnchor.constraint(equalToConstant: 32),
            dateView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            dateView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            dateView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
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
            self.textView.resignFirstResponder()
            self.formViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        if let taskText = textView.text, !taskText.isEmpty {
            onTaskTextUpdate?(taskText, taskDate!)
        }
    }
    
    
    
    // MARK: - Gesture methods
    private lazy var dismissGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        return tapGesture
    }()
    
    private lazy var dateTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateButtonTapped))
        return tapGesture
    }()
    
    // MARK: - Button methods
    @objc private func dateButtonTapped() {
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.appear(sender: self)
        datePickerViewController.onDateSelected = { selectedDate in
            self.taskDate = selectedDate
        }
    }
    
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
        dateLabel.text = formattedDate(from: taskDate ?? Date())
    }
}

// MARK: - Extensions

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
        let date = datePickerViewController.get()
        
        if let taskText = textView.text, !taskText.isEmpty {
            onTaskTextUpdate?(taskText, date)
            animateDismissView()
        }
    }
}



