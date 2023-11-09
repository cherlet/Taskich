import UIKit

class WeekdaysHeaderView: UICollectionReusableView {
    private let daysOfWeek = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
    private var labels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .appBackground
        
        for day in daysOfWeek {
            let label = UILabel()
            label.text = day
            label.textColor = .appGray
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16)
            addSubview(label)
            labels.append(label)
        }
        
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 0
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
