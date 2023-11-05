import UIKit

protocol TaskCellDelegate: AnyObject {
    func archived(_ cell: TaskCell, didCompleteTask task: Task)
    func unarchived(_ cell: TaskCell, didUnarchivedTask task: Task)
}


class TaskCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: TaskCellDelegate?
    private var task: Task?
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var checkmarkButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.addTarget(self, action: #selector(checkmarkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var selectedBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(task: Task) {
        self.task = task
        taskLabel.text = task.text
        updateCheckmarkButton(task.isCompleted)
        self.selectionStyle = .none
        self.checkmarkButton.isSelected = task.isCompleted
    }
    
    // MARK: - Setup Methods
    
    private func setupCell() {
        [selectedBackground, checkmarkButton, taskLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            selectedBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            selectedBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            selectedBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            checkmarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            taskLabel.leadingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: 24),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            taskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Other Methods
    
    @objc private func checkmarkButtonTapped() {
        guard let task = self.task else { return }
        task.isCompleted = !task.isCompleted
        updateCheckmarkButton(task.isCompleted) { [weak self] in
            self?.task = task
            if task.isCompleted {
                self?.delegate?.archived(self!, didCompleteTask: task)
            } else {
                self?.delegate?.unarchived(self!, didUnarchivedTask: task)
            }
        }
    }

    private func updateCheckmarkButton(_ isCompleted: Bool, completion: (() -> Void)? = nil) {
        let imageName = isCompleted ? "square.slash.fill" : "square"
        let textColor = isCompleted ? UIColor.lightGray : UIColor.black
        let textAlpha: CGFloat = isCompleted ? 0.5 : 1.0
        
        UIView.animate(withDuration: 0.15, animations: {
            self.checkmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
            self.taskLabel.textColor = textColor
            self.taskLabel.alpha = textAlpha
        }) { _ in
            completion?()
        }
    }
}
