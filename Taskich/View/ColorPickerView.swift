import UIKit

class ColorPickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var colors = ["BlueColor",
                          "GreenColor",
                          "PurpleColor",
                          "RedColor",
                          "YellowColor",
                          "ClaretColor",
                          "GunmetalColor",
                          "IndigoColor",
                          "NaplesYellowColor",
                          "OlivineColor",
                          "OrangeColor",
                          "RoseColor",
                          "SkyBlueColor",
                          "TiffanyColor",
                          "TomatoColor",
    ]
    private var selectedColorIndex: IndexPath?
    
    private let collectionView: UICollectionView
    private let layout: UICollectionViewFlowLayout
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)

        setupCollectionView()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 30, height: 30)
        
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .appBackground
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        
        if let color = UIColor(named: colors[indexPath.item]) {
            cell.configure(with: color, isSelected: indexPath == selectedColorIndex)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColorIndex = indexPath
        collectionView.reloadData()
    }
    
    func getSelectedColorName() -> String? {
        guard let index = selectedColorIndex else { return nil }
        return colors[index.item]
    }
    
    func selectColor(named colorName: String) {
        if let index = colors.firstIndex(where: { $0 == colorName }) {
            let indexPath = IndexPath(item: index, section: 0)
            selectedColorIndex = indexPath
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView.reloadData()
        }
    }
}





