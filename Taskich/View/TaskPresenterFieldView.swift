import UIKit

class TaskPresenterFieldView: UIView {
    let label = UILabel()
    let image = UIImageView()
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .appGray
        button.isHidden = true
        return button
    }()

    init(text: String, image: String) {
        super.init(frame: .zero)
        
        self.label.text = text
        self.image.image = UIImage(systemName: "\(image)")
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .appBackground
        image.tintColor = .appAccent
        label.textColor = .appGray
        
        [image, label, deleteButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func updateDateLabel(text: String) {
        self.label.text = text
        self.label.textColor = .appText
    }
    
    func updateReminderLabel(_ text: String) {
        self.label.text = text
        self.label.textColor = .appText
        self.deleteButton.isHidden = false
    }
    
    func deleteReminderLabel() {
        self.label.text = "Добавить напоминание"
        self.label.textColor = .appGray
        self.deleteButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
