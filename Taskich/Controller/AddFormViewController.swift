import UIKit

class AddFormViewController: UIViewController {
    
    // MARK: - Constants
    private let defaultHeight: CGFloat = 200
    private let dimmedAlpha: CGFloat = 0.6
    
    // MARK: - Properties
    var onAddButtonTapped: ((String, Date, Tag) -> Void)?
    
    let datePickerViewController = DatePickerViewController()
    var taskDate: Date?
    var tag: Tag?
    
    private var formViewHeightConstraint: NSLayoutConstraint?
    private var formViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.tintColor = .appAccent
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        return button
    }()
    
    private lazy var dateView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.appText.cgColor
        view.layer.borderWidth = 0.7
        view.addGestureRecognizer(dateTapGestureRecognizer)
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = formattedDate(from: taskDate ?? Date())
        label.textColor = .appText
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private lazy var formFooterView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = dimmedAlpha
        return view
    }()
    
    private lazy var tagView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.7
        view.layer.borderColor = UIColor.appText.cgColor
        view.addGestureRecognizer(tagTapGestureRecognizer)
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appText
        label.text = "Тэг"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()
    

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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        textView.delegate = self
        
        [textView, formFooterView, tagView, tagLabel, separatorLine, dateView, dateLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [formFooterView, separatorLine].forEach {
            view.addSubview($0)
        }
        
        tagView.addSubview(tagLabel)
        dateView.addSubview(dateLabel)
        
        [addButton, tagView, dateView].forEach {
            formFooterView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            
            separatorLine.bottomAnchor.constraint(equalTo: formFooterView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            formFooterView.bottomAnchor.constraint(equalTo: formView.safeAreaLayoutGuide.bottomAnchor),
            formFooterView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            formFooterView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            formFooterView.heightAnchor.constraint(equalToConstant: 44),
            
            tagView.centerYAnchor.constraint(equalTo: formFooterView.centerYAnchor),
            tagView.leadingAnchor.constraint(equalTo: formFooterView.leadingAnchor, constant: 16),
            tagView.widthAnchor.constraint(lessThanOrEqualTo: formFooterView.widthAnchor, multiplier: 0.4),
            tagView.heightAnchor.constraint(equalToConstant: 28),
            
            dateView.centerYAnchor.constraint(equalTo: formFooterView.centerYAnchor),
            dateView.centerXAnchor.constraint(equalTo: formFooterView.centerXAnchor),
            dateView.heightAnchor.constraint(equalToConstant: 28),
            dateView.widthAnchor.constraint(lessThanOrEqualToConstant: 164),
            
            addButton.centerYAnchor.constraint(equalTo: formFooterView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: formFooterView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            
            // view's components
            tagLabel.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -12),
            tagLabel.topAnchor.constraint(equalTo: tagView.topAnchor, constant: 4),
            tagLabel.bottomAnchor.constraint(equalTo: tagView.bottomAnchor, constant: -4),
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: dateView.trailingAnchor, constant: -12),
            dateLabel.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: dateView.bottomAnchor, constant: -4),
            dateLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor),
        ])
    }
    
    // MARK: - Action methods
    @objc private func addButtonTapped() {
        let date = datePickerViewController.get()
        
        if let taskText = textView.text, let taskTag = tag {
            onAddButtonTapped?(taskText, date, taskTag)
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
    
    @objc private func tagViewTapped() {
        let tagListViewController = TagListViewController()
        textView.resignFirstResponder()
        tagListViewController.modalPresentationStyle = .overFullScreen
        tagListViewController.onDismiss = { [weak self] in
            self?.textView.becomeFirstResponder()
        }
        tagListViewController.tagSelected = { [weak self] tag in
            self?.tag = tag
            self?.updateTagView()
        }
        tagListViewController.appear(sender: self)
    }
    
    private lazy var tagTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tagViewTapped))
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
    
    private func updateTagView() {
        tagView.backgroundColor = UIColor(named: tag?.color ?? "")
        tagView.layer.borderWidth = 0
        tagLabel.textColor = .white
        tagLabel.text = tag?.name
        tagView.layoutIfNeeded()
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
