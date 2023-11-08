import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func didSelect(menuItem: Int)
}

class MenuViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: MenuViewControllerDelegate?
    private let menuTagsView = MenuTagsView()
    
    private lazy var tasks: MenuItemView = {
        let item = MenuItemView()
        item.image.image = UIImage(systemName: "bookmark")
        item.label.text = "Главный экран"
        item.setupView()
        return item
    }()
    
    private lazy var archive: MenuItemView = {
        let item = MenuItemView()
        item.image.image = UIImage(systemName: "archivebox")
        item.label.text = "Архив"
        item.setupView()
        return item
    }()
    
    private lazy var trash: MenuItemView = {
        let item = MenuItemView()
        item.image.image = UIImage(systemName: "trash")
        item.label.text = "Корзина"
        item.setupView()
        return item
    }()
    
    private lazy var tags: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var tagsLabel: UILabel = {
        let label = UILabel()
        label.text = "ТЭГИ"
        label.font = UIFont.preferredFont(forTextStyle: .headline).withSize(16)
        label.textColor = .gray.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var tagsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(tagAddButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        
        tasks.addGestureRecognizer(tasksTapGestureRecognizer)
        archive.addGestureRecognizer(archiveTapGestureRecognizer)
        trash.addGestureRecognizer(trashGestureRecognizer)
        
        // tags config
        [tagsLabel, tagsButton].forEach {
            tags.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: tags.leadingAnchor, constant: 16),
            tagsLabel.centerYAnchor.constraint(equalTo: tags.centerYAnchor),
            
            tagsButton.trailingAnchor.constraint(equalTo: tags.trailingAnchor, constant: -24),
            tagsButton.centerYAnchor.constraint(equalTo: tags.centerYAnchor)
        ])
        
        // menu config
        [tasks, archive, tags, trash].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }
        
        view.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(menuTagsView)
        menuTagsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tasks.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            archive.topAnchor.constraint(equalTo: tasks.bottomAnchor, constant: 12),
            tags.topAnchor.constraint(equalTo: archive.bottomAnchor, constant: 16),
            
            menuTagsView.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 8),
            menuTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            menuTagsView.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),
            
            trash.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120),
            separatorLine.bottomAnchor.constraint(equalTo: trash.topAnchor, constant: -16)
        ])
    }
    
    private lazy var tasksTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tasksViewTapped))
        return tapGesture
    }()
    
    private lazy var archiveTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(archiveViewTapped))
        return tapGesture
    }()
    
    private lazy var trashGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trashViewTapped))
        return tapGesture
    }()
    
    @objc private func tasksViewTapped() {
        delegate?.didSelect(menuItem: 0)
    }
    
    @objc private func archiveViewTapped() {
        delegate?.didSelect(menuItem: 1)
    }
    
    @objc private func trashViewTapped() {
        delegate?.didSelect(menuItem: 2)
    }
    
    @objc private func tagAddButtonTapped() {
        print("LETS GOOOOOOOOOOO")
    }
}
