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
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.tintColor = .black
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
            checkmarkButton.widthAnchor.constraint(equalToConstant: 32),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 32),
            
            taskLabel.leadingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: 32),
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        checkmarkButton.addTarget(self, action: #selector(checkmarkButtonTapped), for: .touchUpInside)
    }
    
    @objc private func checkmarkButtonTapped() {
        guard var task = self.task else { return }
        task.isCompleted = !task.isCompleted

        if task.isCompleted {
            UIView.animate(withDuration: 0.3) {
                self.checkmarkButton.setImage(UIImage(systemName: "square.slash.fill"), for: .normal)
                self.taskLabel.textColor = .lightGray
                self.taskLabel.alpha = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.checkmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
                self.taskLabel.textColor = .black
                self.taskLabel.alpha = 1.0
            }
        }

        
        self.task = task
    }

}
