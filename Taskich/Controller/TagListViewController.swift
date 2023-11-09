import UIKit

class TagListViewController: UIViewController {
    // MARK: - Properties
    var tags = [Tag]()
    var tagSelected: ((Tag?) -> Void)?
    var onDismiss: (() -> Void)?
    
    var replacedTag: Tag?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TagCell.self, forCellReuseIdentifier: "TagCell")
        table.separatorStyle = .singleLine
        table.backgroundColor = .appBackground
        return table
    }()
    
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var deleteAllView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        return view
    }()
    
    private lazy var deleteLabel: UILabel = {
        let label = UILabel()
        label.text = "Удалить с задачами"
        label.textColor = .appGray
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
        updateData()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .clear
        
        dimmedView.addGestureRecognizer(tapGestureRecognizer)
        
        [dimmedView, formView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            formView.widthAnchor.constraint(equalToConstant: 360),
            formView.heightAnchor.constraint(equalToConstant: 280),
            formView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupTableView() {
        formView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: formView.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupToReplace() {
        formView.addSubview(deleteAllView)
        formView.addSubview(separatorLine)
        formView.addSubview(tableView)
        deleteAllView.addSubview(deleteLabel)
        
        deleteAllView.addGestureRecognizer(deleteAllGestureRecognizer)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        deleteAllView.translatesAutoresizingMaskIntoConstraints = false
        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deleteAllView.topAnchor.constraint(equalTo: formView.topAnchor, constant: 8),
            deleteAllView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            deleteAllView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            deleteAllView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorLine.topAnchor.constraint(equalTo: deleteAllView.bottomAnchor, constant: 8),
            separatorLine.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            tableView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -16),
            
            deleteLabel.leadingAnchor.constraint(equalTo: deleteAllView.leadingAnchor, constant: 16),
            deleteLabel.centerYAnchor.constraint(equalTo: deleteAllView.centerYAnchor),
        ])
    }
    
    // MARK: - Core Data
    func updateData() {
        if let tag = replacedTag {
            tags = StorageManager.shared.fetchTagsWithoutTag(with: tag.id)
        } else {
            tags = StorageManager.shared.fetchTags()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Animations/actions
    func appear(sender: UIViewController, toReplace: Tag? = nil) {
        if toReplace != nil {
            self.replacedTag = toReplace
            setupToReplace()
        } else {
            setupTableView()
        }
        
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = 0.6
            self.formView.alpha = 1
        }
    }
    
    @objc private func hide() {
        UIView.animate(withDuration: 0.15) {
            self.dimmedView.alpha = 0
            self.formView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.onDismiss?()
            self.removeFromParent()
        }
    }
    
    @objc private func deleteAll() {
        tagSelected?(nil)
        hide()
    }
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        return tapGesture
    }()
    
    private lazy var deleteAllGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAll))
        return tapGesture
    }()
}

// MARK: - UITableViewDelegate
extension TagListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tagSelected?(tags[indexPath.row])
        hide()
    }
}

// MARK: - UITableViewDataSource
extension TagListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as? TagCell else { fatalError() }
        
        cell.configure(tag: tags[indexPath.row])
        return cell
    }
}
