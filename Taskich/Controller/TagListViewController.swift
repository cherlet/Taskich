import UIKit

class TagListViewController: UIViewController {
    // MARK: - Properties
    var tags = [Tag]()
    var tagSelected: ((Tag) -> Void)?
    var onDismiss: (() -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TagCell.self, forCellReuseIdentifier: "TagCell")
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
        setupTableView()
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
            formView.heightAnchor.constraint(equalToConstant: 360),
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
            tableView.leadingAnchor.constraint(equalTo: formView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: formView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: formView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Core Data
    func updateData() {
        tags = StorageManager.shared.fetchTags()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Animations/actions
    func appear(sender: UIViewController) {
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
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
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
