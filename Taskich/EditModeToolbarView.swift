//
//  EditModeToolbarView.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 02.10.2023.
//

import UIKit

class EditModeToolbarView: UIStackView {
    
    lazy var tagButton: UIButton = {
        let button = UIButton(configuration: configureButton(title: "Тэг",
                                                             image: "tag",
                                                             color: .black))
        return button
    }()
    
    lazy var dateButton: UIButton = {
        let button = UIButton(configuration: configureButton(title: "Дата",
                                                             image: "calendar",
                                                             color: .black))
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(configuration: configureButton(title: "Удалить",
                                                             image: "trash",
                                                             color: .red))
        return button
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

        [tagButton, dateButton, deleteButton].forEach {
            addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        layer.cornerRadius = 8
        axis = .horizontal
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 20)
        alignment = .center
        distribution = .equalSpacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditModeToolbarView {
    private func configureButton(title: String, image: String, color: UIColor) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = UIImage(systemName: image)
        configuration.title = title
        configuration.baseForegroundColor = color
        
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                              leading: 0,
                                                              bottom: 0,
                                                              trailing: 0)
        
        return configuration
    }
}

