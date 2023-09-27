import UIKit

class TaskListViewController: UITableViewController,  UITableViewDragDelegate, UITableViewDropDelegate {
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        getTestCells()
    }

    // MARK: - Setup methods
    
    private func setupTableView() {
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .none
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    
    private func setupNavigationBar() {
        title = "Taskich"
        
        let addTaskButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(addTask))
        addTaskButton.tintColor = .black
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    // MARK: - Private methods
    
    @objc private func addTask() {
        let addFormController = AddFormViewController()
        addFormController.modalPresentationStyle = .overCurrentContext
        present(addFormController, animated: false)
        
        addFormController.onAddButtonTapped = { [weak self] taskText in
            if !taskText.isEmpty {
                let newTask = Task(label: taskText, isCompleted: false)
                self?.tasks.append(newTask)
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError()
        }
        
        cell.configure(task: tasks[indexPath.row])
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTask = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(movedTask, at: destinationIndexPath.row)
    }
    
    // MARK: Drag&Drop protocol
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let task = tasks[indexPath.row]
        let itemProvider = NSItemProvider(object: task.label as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            guard let taskLabels = items as? [String] else { return }
            let taskLabel = taskLabels.first
            if let index = self.tasks.firstIndex(where: { $0.label == taskLabel }) {
                let movedTask = self.tasks.remove(at: index)
                self.tasks.insert(movedTask, at: destinationIndexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Test Methods
    
    private func getTestCells() {
        tasks.append(Task(label: "Short task", isCompleted: false))
        tasks.append(Task(label: "Medium length task for testing", isCompleted: false))
        tasks.append(Task(label: "A longer task label for testing purposes", isCompleted: false))
        tasks.append(Task(label: "This is a quite long task label for testing different lengths", isCompleted: false))
        tasks.append(Task(label: "This is a very very very very very very very long task label to test maximum length situations", isCompleted: false))
    }
}
