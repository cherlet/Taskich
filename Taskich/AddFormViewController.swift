//
//  AddFormViewController.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 23.09.2023.
//

import UIKit

class AddFormViewController: UIViewController {
    
    
    // MARK: - View Properties
    
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = dimmedAlpha
        return view
    }()
    
    private let defaultHeight: CGFloat = 500
    private let dimmedAlpha: CGFloat = 0.6
    private var formViewHeightConstraint: NSLayoutConstraint?
    private var formViewBottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - Model properties
    
    let textField = UITextField()
    let addButton = UIButton()
    var onAddButtonTapped: ((String) -> Void)?
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
    }
    
    // MARK: - Button action methods
    
    @objc private func addButtonTapped() {
        if let taskText = textField.text {
            onAddButtonTapped?(taskText)
        }
        
        animateDismissView()
    }
    
    // MARK: - Setup methods
    
    private func setupView() {
        view.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(formView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        formView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        
        formViewHeightConstraint = formView.heightAnchor.constraint(equalToConstant: defaultHeight)
        formViewBottomConstraint = formView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
        formViewHeightConstraint?.isActive = true
        formViewBottomConstraint?.isActive = true
    }
    
    private func setupForm() {
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
            textField.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -64),
            
            addButton.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16)
        ])
    }
    
    // MARK: - Animate methods
    
    private func animatePresentForm() {
        UIView.animate(withDuration: 0.3) {
            self.formViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0) {
            self.dimmedView.alpha = self.dimmedAlpha
        } completion: { _ in
            self.textField.becomeFirstResponder()
            self.animatePresentForm()
        }
    }
    
    private func animateDismissView() {
        dimmedView.alpha = dimmedAlpha
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.textField.resignFirstResponder()
            self.formViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
}
