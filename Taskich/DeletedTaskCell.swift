import UIKit

protocol DeletedTaskCellDelegate: AnyObject {
    func returnTask(_ cell: DeletedTaskCell, task: Task)
}

class DeletedTaskCell: UITableViewCell {
    
    weak var delegate: DeletedTaskCellDelegate?
    private var task: Task?
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "return"), for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(returnButton)
        
        NSLayoutConstraint.activate([
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            returnButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            returnButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            returnButton.widthAnchor.constraint(equalToConstant: 20),
            returnButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(task: Task) {
        self.task = task
        taskLabel.text = task.label
        taskLabel.textColor = .gray
        self.selectionStyle = .none
        returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
    }
    
    @objc private func returnButtonTapped() {
        guard let task = self.task else { return }
        self.delegate?.returnTask(self, task: task)
    }
}
