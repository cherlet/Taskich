import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: - Properties
    
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
        taskLabel.text = task.label
        updateCheckmarkButton(task.isCompleted)
        self.selectionStyle = .none
    }
    
    // MARK: - Setup Methods
    
    private func setupCell() {
        [selectedBackground, checkmarkButton, taskLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            selectedBackground.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
            selectedBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -5),
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
        guard var task = self.task else { return }
        task.isCompleted = !task.isCompleted
        updateCheckmarkButton(task.isCompleted)
        self.task = task
    }
    
    private func updateCheckmarkButton(_ isCompleted: Bool) {
        let imageName = isCompleted ? "square.slash.fill" : "square"
        let textColor = isCompleted ? UIColor.lightGray : UIColor.black
        let textAlpha: CGFloat = isCompleted ? 0.5 : 1.0
        
        UIView.animate(withDuration: 0.3) {
            self.checkmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
            self.taskLabel.textColor = textColor
            self.taskLabel.alpha = textAlpha
        }
    }
}
