//
//  AddFormViewController.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 23.09.2023.
//

import UIKit

class AddFormViewController: UIViewController {
    
    let textField = UITextField()
    let addButton = UIButton()
    var onAddButtonTapped: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        textField.placeholder = "Задача"
        let configuration = UIImage.SymbolConfiguration(pointSize: 24)
        addButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: configuration), for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.tintColor = .black
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        
        [textField, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            
            //addButton.widthAnchor.constraint(equalToConstant: 32),
            //addButton.heightAnchor.constraint(equalToConstant: 32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        ])
    }
    
    // MARK: - Private methods
    
    @objc private func addButtonTapped() {
        if let taskText = textField.text {
            onAddButtonTapped?(taskText)
        }
        dismiss(animated: true, completion: nil)
    }
}
