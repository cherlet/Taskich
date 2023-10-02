//
//  EditModeToolbarView.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 02.10.2023.
//

import UIKit

class EditModeToolbarView: UIView {
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

