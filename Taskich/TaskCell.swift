//
//  TaskCell.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 20.09.2023.
//

import UIKit

class TaskCell: UITableViewCell {
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkmarkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(task: Task){
        taskLabel.text = task.label
    }
    
    // MARK: Private
    
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
    }
}
