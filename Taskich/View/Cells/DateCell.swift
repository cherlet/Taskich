import UIKit

class DateCell: UICollectionViewCell {
    private let label = UILabel()
    private var day: Day?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with day: Day) {
        self.day = day
        
        let calendar = Calendar.current
        let dayLabel = calendar.component(.day, from: day.date)
        
        label.text = "\(dayLabel)"
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        label.layer.cornerRadius = 20
        
        if day.state.isSelected {
            label.textColor = .systemGreen
            label.layer.borderWidth = 1.5
            label.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            label.layer.borderWidth = 0
            label.layer.borderColor = nil
            
            if day.state.isCurrent {
                label.textColor = .systemGreen
            } else if day.state.isPast {
                label.textColor = .gray
            } else {
                label.textColor = .black
            }
        }
    }
    
    func configureAsEmpty() {
        label.text = ""
        label.layer.borderWidth = 0
        label.layer.borderColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
    }
}
