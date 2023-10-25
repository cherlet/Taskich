import UIKit

class DatePickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var days: [Day] = []
    private let collectionView: UICollectionView
    private let layout: UICollectionViewFlowLayout
    private var selectedDate: Date?
    private var currentDate: Date = Date()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        return button
    }()
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        return button
    }()

    
    
    override init(frame: CGRect) {
        
        layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
            nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
            updateButtonsState()
        
        collectionView.register(WeekdaysHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "WeekdaysHeaderViewID")
        
        setupCollectionView()
        setupCalendar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.backgroundColor = .clear
        
        let width = collectionView.frame.width / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 50)
        layout.sectionHeadersPinToVisibleBounds = true
        
        
        [previousButton, monthLabel, nextButton, separatorLine, collectionView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            separatorLine.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            collectionView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupCalendar() {
        setupMonth()
        collectionView.reloadData()
    }
    
    
    // MARK: - UICollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count + emptyDaysAtStart()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        if isIndexPathEmpty(indexPath) {
            cell.configureAsEmpty()
        } else {
            let day = days[indexPath.row - emptyDaysAtStart()]
            cell.configure(with: day)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        if isLittleSpace() {
            return CGSize(width: width, height: width - 9.3)
        }
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WeekdaysHeaderViewID", for: indexPath) as! WeekdaysHeaderView
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isIndexPathEmpty(indexPath) {
            return false
        }
        return !days[indexPath.row - emptyDaysAtStart()].state.isPast
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let adjustedIndex = indexPath.row - emptyDaysAtStart()
        if adjustedIndex < 0 || adjustedIndex >= days.count {
            return
        }
        
        let day = days[adjustedIndex]
        selectedDate = day.date
        
        for (index, _) in days.enumerated() {
            days[index].state.isSelected = day.date == days[index].date
        }
        
        collectionView.reloadData()
    }
    
    
    // MARK: - Other methods
    
    private func emptyDaysAtStart() -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        if let firstDateOfMonth = Calendar.current.date(from: components) {
            let weekday = Calendar.current.component(.weekday, from: firstDateOfMonth)
            return (weekday + 5) % 7
        }
        return 0
    }
    
    private func isIndexPathEmpty(_ indexPath: IndexPath) -> Bool {
        return indexPath.row < emptyDaysAtStart()
    }
    
    private func adjustCurrentDate(by numberOfMonths: Int) {
        var newDateComponents = DateComponents()
        newDateComponents.month = numberOfMonths
        
        if let newDate = Calendar.current.date(byAdding: newDateComponents, to: currentDate) {
            currentDate = newDate
            setupCalendar()
        }
        
        updateButtonsState()
    }
    
    private func setupMonth() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        guard let startDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startDate)
        else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let monthName = dateFormatter.standaloneMonthSymbols[components.month! - 1].capitalized
        if components.year == Calendar.current.component(.year, from: Date()) {
            monthLabel.text = monthName
        } else {
            monthLabel.text = "\(monthName) \(components.year!)"
        }
        
        days.removeAll()
        
        let today = Date()
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startDate) else { continue }
            
            let isCurrent = calendar.isDate(date, inSameDayAs: today)
            let isSelected: Bool
            if selectedDate == nil {
                isSelected = isCurrent
            } else {
                isSelected = calendar.isDate(date, equalTo: selectedDate!, toGranularity: .day)
            }
            let isPast: Bool
            if calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending {
                isPast = true
            } else {
                isPast = false
            }
            
            let state = State(isSelected: isSelected, isCurrent: isCurrent, isPast: isPast)
            let dayItem = Day(date: date, state: state)
            
            days.append(dayItem)
        }
    }
    
    private func moveToNextMonth() {
        adjustCurrentDate(by: 1)
    }
    
    private func moveToPreviousMonth() {
        adjustCurrentDate(by: -1)
    }
    
    @objc private func didTapPreviousButton() {
        moveToPreviousMonth()
        updateButtonsState()
    }

    @objc private func didTapNextButton() {
        moveToNextMonth()
        updateButtonsState()
    }

    private func updateButtonsState() {
        let currentYearMonth = Calendar.current.dateComponents([.year, .month], from: Date())
        let displayedYearMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
        
        previousButton.isEnabled = !(displayedYearMonth.year == currentYearMonth.year && displayedYearMonth.month == currentYearMonth.month)
        
        if previousButton.isEnabled {
            previousButton.tintColor = .black
        } else {
            previousButton.tintColor = .gray
        }
    }
    
    private func isLittleSpace() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let firstDay = calendar.date(from: components)!
        
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let numberOfDays = range.count
        
        let weekday = calendar.component(.weekday, from: firstDay)
        
        if weekday == 7 && numberOfDays > 30 {
            return true
        } else if weekday == 1 && numberOfDays > 29 {
            return true
        }
        
        return false
    }
    
    func getDate() -> Date {
        var date = selectedDate ?? Date()
        let timeZoneSeconds = TimeZone.current.secondsFromGMT()
        date = date.addingTimeInterval(TimeInterval(timeZoneSeconds))
        return date
    }
}

