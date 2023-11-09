import UIKit

class ArchiveViewController: UIViewController {
    
    // MARK: - Properties
    var archivedTasks: [Task] = []
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        table.separatorStyle = .none
        table.backgroundColor = .appBackground
        return table
    }()
    
    // MARK: - Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
        updateData()
        view.backgroundColor = .appBackground
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        title = "Архив"
        view.backgroundColor = .appBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Core Data
    func updateData() {
        archivedTasks = StorageManager.shared.fetchArchivedTasks()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError("Failed to dequeue a TaskCell.")
        }
        cell.configure(task: archivedTasks[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - TaskCellDelegate

extension ArchiveViewController: TaskCellDelegate {

    func archived(_ cell: TaskCell, didCompleteTask task: Task) {}
    
    func unarchived(_ cell: TaskCell, didUnarchivedTask task: Task) {
        if let index = archivedTasks.firstIndex(where: { $0.text == task.text && $0.date == task.date }) {
            let unarchivedTask = archivedTasks[index]
            StorageManager.shared.returnFromArchive(task: unarchivedTask.id)
            self.updateData()
            if let navigationController = parent as? UINavigationController,
               let containerVC = navigationController.parent as? ContainerViewController {
                containerVC.updateCurrent()
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            tableView.endUpdates()
        }
    }
}
