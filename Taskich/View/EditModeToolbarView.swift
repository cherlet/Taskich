import UIKit

class EditModeToolbarView: UIStackView {
    
    // MARK: - Properties
    lazy var dateButton: UIButton = {
        let button = UIButton(configuration: configureButton(title: "Дата",
                                                             image: "calendar",
                                                             color: .white))
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(configuration: configureButton(title: "Удалить",
                                                             image: "trash",
                                                             color: .white))
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let dateButtonContainer = createButtonContainer(for: dateButton, color: UIColor.gray.withAlphaComponent(0.5))
        let deleteButtonContainer = createButtonContainer(for: deleteButton, color: UIColor.red.withAlphaComponent(0.5))
        
        [dateButtonContainer, deleteButtonContainer].forEach {
            addArrangedSubview($0)
        }
        
        backgroundColor = .clear
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
    }
    
    // MARK: - Helper Methods
    private func createButtonContainer(for button: UIButton, color: UIColor) -> UIView {
        let container = UIView()
        container.addSubview(button)
        container.backgroundColor = color
        container.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }

    private func configureButton(title: String, image: String, color: UIColor) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: image)
        configuration.title = title
        configuration.baseForegroundColor = color
        configuration.imagePadding = 4
        return configuration
    }
}
