//
//  TaskCell.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 20.09.2023.
//

import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: Properties
    
    private var task: Task?
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(task: Task) {
        self.task = task
        taskLabel.text = task.label
    }

    
    // MARK: Private Methods
    
    private func setupCell() {
        contentView.addSubview(taskLabel)
        contentView.addSubview(checkmarkButton)
        
        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            taskLabel.leadingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: 32),
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        checkmarkButton.addTarget(self, action: #selector(checkmarkButtonTapped), for: .touchUpInside)
    }
    
    @objc private func checkmarkButtonTapped() {
        guard var task = self.task else { return }
        task.isCompleted = !task.isCompleted

        if task.isCompleted {
            checkmarkButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            taskLabel.textColor = .lightGray
            taskLabel.attributedText = NSAttributedString(string: task.label, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        } else {
            checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
            taskLabel.textColor = .black
            taskLabel.attributedText = NSAttributedString(string: task.label, attributes: [:])
        }
        
        self.task = task
    }

}
