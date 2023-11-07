import UIKit

class AddFormViewController: UIViewController {
    
    // MARK: - Constants
    private let defaultHeight: CGFloat = 200
    private let dimmedAlpha: CGFloat = 0.6
    
    // MARK: - Properties
    let addButton = UIButton()
    var onAddButtonTapped: ((String, Date) -> Void)?
    
    let datePickerViewController = DatePickerViewController()
    let dateView = UIView()
    let dateImage = UIImageView(image: UIImage(systemName: "calendar"))
    let dateLabel = UILabel()
    var taskDate: Date?
    
    private var formViewHeightConstraint: NSLayoutConstraint?
    private var formViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
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
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateView, addButton])
        stack.backgroundColor = .white
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    

    let textView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.returnKeyType = .done
        return tv
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFields()
        setupForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        animateDimmedView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setup methods
    private func setupView() {
        dimmedView.addGestureRecognizer(tapGestureRecognizer)
        formView.addGestureRecognizer(swipeDownGestureRecognizer)

        
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
        
        formView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            
            separatorLine.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: formView.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupFields() {
        dateView.backgroundColor = .clear
        dateImage.tintColor = .black
        dateLabel.text = formattedDate(from: taskDate ?? Date())
        dateView.addGestureRecognizer(dateTapGestureRecognizer)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.tintColor = .black
        if let resizedImage = UIImage(systemName: "arrow.up.circle.fill")?.resize(to: CGSize(width: 28, height: 28)) {
            addButton.setImage(resizedImage, for: .normal)
        }

        
        
        [dateImage, dateLabel].forEach {
            dateView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            dateImage.leadingAnchor.constraint(equalTo: dateView.leadingAnchor),
            dateImage.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateImage.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
            
            dateView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Action methods
    @objc private func addButtonTapped() {
        let date = datePickerViewController.get()
        
        if let taskText = textView.text {
            onAddButtonTapped?(taskText, date)
        }
        
        animateDismissView()
    }
    
    @objc private func dateButtonTapped() {
        textView.resignFirstResponder()
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.onDismiss = { [weak self] in
            self?.textView.becomeFirstResponder()
        }
        datePickerViewController.onDateSelected = { selectedDate in
            self.taskDate = selectedDate
            self.updateDateLabel()
        }
        datePickerViewController.appear(sender: self)
    }
    
    private lazy var dateTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateButtonTapped))
        return tapGesture
    }()

    
    // MARK: - Animation Methods
    private func animateDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = self.dimmedAlpha
        } completion: { _ in
            self.textView.becomeFirstResponder()
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
    }

    // MARK: - Keyboard Handling
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            formViewBottomConstraint?.constant = -keyboardSize.height
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        formViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper Methods
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
        dateLabel.text = formattedDate(from: taskDate ?? Date())
    }
    
    // MARK: - Gesture methods
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        return tapGesture
    }()
    
    private lazy var swipeDownGestureRecognizer: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(animateDismissView))
        gestureRecognizer.direction = .down
        return gestureRecognizer
    }()
}

// MARK: - UITextViewDelegate
extension AddFormViewController: UITextViewDelegate {
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
            if let taskText = textView.text, !taskText.isEmpty {
                addButtonTapped()
            }
            return false
        }
        return true
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
