import UIKit

class TrashViewController: UIViewController {

    // MARK: - Properties
    private var tasks: [Task] = []
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Очистить корзину", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(deleteAllTasks), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DeletedTaskCell.self, forCellReuseIdentifier: "DeletedTaskCell")
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        title = "Корзина"
        view.backgroundColor = .white
    
        [deleteAllButton, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            deleteAllButton.heightAnchor.constraint(equalToConstant: 40),
            deleteAllButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            deleteAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            deleteAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            
            tableView.topAnchor.constraint(equalTo: deleteAllButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Task Management
    func addTask(task: Task) {
        tasks.append(task)
        tableView.reloadData()
    }
    
    @objc private func deleteAllTasks() {
        let actionSheet = UIAlertController(title: nil, message: "Вы действительно хотите удалить все задачи?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.tasks.removeAll()
            self?.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = deleteAllButton
            popoverController.sourceRect = deleteAllButton.bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TrashViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeletedTaskCell", for: indexPath) as? DeletedTaskCell else {
            fatalError("Failed to dequeue a DeletedTaskCell.")
        }
        
        cell.delegate = self
        cell.configure(task: tasks[indexPath.row])
        return cell
    }
}

// MARK: - DeletedTaskCellDelegate
extension TrashViewController: DeletedTaskCellDelegate {
    
    func returnTask(_ cell: DeletedTaskCell, task: Task) {
        if let index = tasks.firstIndex(where: { $0.label == task.label && $0.date == task.date }) {
            let returnedTask = tasks.remove(at: index)
            if let navigationController = parent as? UINavigationController,
               let containerVC = navigationController.parent as? ContainerViewController {
                containerVC.returnDeletedTask(task: returnedTask)
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
}
