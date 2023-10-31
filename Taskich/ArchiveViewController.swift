import UIKit

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
    }
    
    private func setupView() {
        title = "Архив"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addTask(task: Task) {
        var completedTask = task
        completedTask.isCompleted = true
        tasks.append(completedTask)
        tableView.reloadData()
    }

    
    // MARK: - Tabel
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        table.separatorStyle = .none
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError()
        }
        cell.configure(task: tasks[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension ArchiveViewController: TaskCellDelegate {
    func archived(_ cell: TaskCell, didCompleteTask task: Task) {
        //
    }
    
    func unarchived(_ cell: TaskCell, didUnarchivedTask task: Task) {
        if let index = tasks.firstIndex(where: { $0.label == task.label && $0.date == task.date }) {
            let unarchivedTask = tasks.remove(at: index)
            if let navigationController = parent as? UINavigationController,
               let containerVC = navigationController.parent as? ContainerViewController {
                containerVC.unarchivedTask(task: unarchivedTask)
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
}
