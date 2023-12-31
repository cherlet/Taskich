import UIKit

class TagCell: UITableViewCell {
    // MARK: - Properties
    private var taskTag: Tag?
    var isEditingMode = false
    
    var onEditButton: (() -> Void)?
    var onDeleteButton: (() -> Void)?
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private let circleSize: CGFloat = 8
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = circleSize / 2
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appGray.withAlphaComponent(0.8)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.addTarget(self,
                         action: #selector(editButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appDelete.withAlphaComponent(0.8)
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.addTarget(self,
                         action: #selector(deleteButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private let buttonSize: CGFloat = 32
    private var deleteButtonTrailingConstraint: NSLayoutConstraint?
    
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(tag: Tag) {
        self.taskTag = tag
        self.tagLabel.text = tag.name
        self.backgroundColor = .appBackground
        circleView.backgroundColor = UIColor(named: tag.color)
        self.selectionStyle = .none
    }
    
    // MARK: - Setup Methods
    
    private func setupCell() {
        [circleView, tagLabel, editButton, deleteButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        deleteButtonTrailingConstraint = deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 70)
        
        deleteButtonTrailingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: circleSize),
            circleView.heightAnchor.constraint(equalToConstant: circleSize),
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            circleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            tagLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            tagLabel.leadingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: 32),
            
            deleteButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: buttonSize),
            
            editButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: buttonSize),
            editButton.heightAnchor.constraint(equalToConstant: buttonSize),
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -4)
        ])
    }
    
    // MARK: - Action methods
    
    @objc private func deleteButtonTapped() {
        onDeleteButton?()
    }
    
    @objc private func editButtonTapped() {
        onEditButton?()
    }
    
    func configureEditingTools(isEditingMode: Bool) {
        self.isEditingMode = isEditingMode
        if isEditingMode {
            UIView.animate(withDuration: 0.2) {
                self.deleteButtonTrailingConstraint?.constant = -60
                self.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.deleteButtonTrailingConstraint?.constant = 70
                self.layoutIfNeeded()
            }
        }
    }
    
}
