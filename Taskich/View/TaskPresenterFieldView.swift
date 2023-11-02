//
//  TaskPresenterFieldView.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 02.11.2023.
//

import UIKit

class TaskPresenterFieldView: UIView {
    let label = UILabel()
    let image = UIImageView()

    init(text: String, image: String) {
        super.init(frame: .zero)
        
        self.label.text = text
        self.image.image = UIImage(systemName: "\(image)")
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        image.tintColor = .systemGreen
        label.textColor = .gray
        
        [image, label].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func updateDateLabel(text: String) {
        self.label.text = text
        self.label.textColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
