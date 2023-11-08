import UIKit

class MenuItemView: UIView {
    let label = UILabel()
    let image = UIImageView()
    
    func setupView() {
        backgroundColor = .clear
        image.tintColor = .gray
        label.textColor = .black
        
        [image, label].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
}
