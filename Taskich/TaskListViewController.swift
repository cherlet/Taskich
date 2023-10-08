import UIKit

class TaskListViewController: UITableViewController,  UITableViewDragDelegate, UITableViewDropDelegate {
    
    // MARK: - Model Properties
    var tasks = [Task]()
    var isEditingMode = false
    var selectedRows = Set<Int>()
    var editModeToolbar = EditModeToolbarView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        setupEditModeToolbar()
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
        
        if isEditingMode {
            let cancelTaskButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left.circle"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(cancelEditing))
            cancelTaskButton.tintColor = .black
            navigationItem.rightBarButtonItem = cancelTaskButton
        } else {
            let addTaskButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(addTask))
            addTaskButton.tintColor = .black
            navigationItem.rightBarButtonItem = addTaskButton
        }
    }
    
    private func setupEditModeToolbar() {
        view.addSubview(editModeToolbar)
        editModeToolbar.isHidden = true
        
        editModeToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editModeToolbar.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
            editModeToolbar.heightAnchor.constraint(equalToConstant: 48),
            
            editModeToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -5),
            editModeToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        editModeToolbar.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Config reusable cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError()
        }
        
        // Swipe gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureRecognizer(_:)))
        swipeLeftGesture.direction = .left
        cell.addGestureRecognizer(swipeLeftGesture)
        
        // TaskCell.configure
        cell.configure(task: tasks[indexPath.row])
        
        // Design for editingMode
        if selectedRows.contains(indexPath.row) {
            cell.layer.cornerRadius = 8
            cell.selectedBackground.isHidden = false
        } else {
            cell.layer.cornerRadius = 0
            cell.selectedBackground.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            if selectedRows.contains(indexPath.row) {
                selectedRows.remove(indexPath.row)
            } else {
                selectedRows.insert(indexPath.row)
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
            
            if selectedRows.isEmpty {
                cancelEditing()
            }
        } else {
            presentTask(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if isEditingMode {
            cancelEditing()
        }
        
        let movedTask = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(movedTask, at: destinationIndexPath.row)
    }
    
    // MARK: - Drag&Drop protocol
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let task = tasks[indexPath.row]
        let itemProvider = NSItemProvider(object: task.label as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        editModeToolbar.isHidden = true
        
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
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let bezierPath = UIBezierPath(roundedRect:cell.bounds.insetBy(dx: 8, dy: 0),
                                          cornerRadius: 8.0)
            
            previewParameters.visiblePath = bezierPath
        }
        
        return previewParameters
    }
    
    // MARK: - Present Methods
    @objc private func addTask() {
        let addFormController = AddFormViewController()
        addFormController.modalPresentationStyle = .overCurrentContext
        present(addFormController, animated: false)
        
        addFormController.onAddButtonTapped = { taskText in
            if !taskText.isEmpty {
                let newTask = Task(label: taskText, isCompleted: false)
                self.tasks.append(newTask)
                self.tableView.reloadData()
            }
        }
    }
    
    private func presentTask(at indexPath: IndexPath) {
        let presenterViewController = TaskPresenterViewController()
        presenterViewController.modalPresentationStyle = .overCurrentContext
        
        presenterViewController.taskText = tasks[indexPath.row].label
        
        presenterViewController.onTaskTextUpdate = { newText in
            self.tasks[indexPath.row].label = newText
            self.tableView.reloadData()
        }
        
        present(presenterViewController, animated: false)
    }
    
    // MARK: - Other Methods
    @objc private func leftSwipeGestureRecognizer(_ gesture: UISwipeGestureRecognizer) {
        
        guard let indexPath = tableView.indexPathForRow(at: gesture.location(in: tableView)),
              let cell = tableView.cellForRow(at: indexPath)
        else {
            return
        }
        
        isEditingMode = true
        editModeToolbar.isHidden = false
        setupNavigationBar()
        
        if selectedRows.contains(indexPath.row) {
            selectedRows.remove(indexPath.row)
        } else {
            selectedRows.insert(indexPath.row)
        }
        
        leftSwipeGestureAnimation(for: cell, at: indexPath)
    }
    
    @objc private func cancelEditing() {
        isEditingMode = false
        selectedRows.removeAll()
        editModeToolbar.isHidden = true
        setupNavigationBar()
        tableView.reloadData()
    }
    
    private func leftSwipeGestureAnimation(for cell: UITableViewCell, at indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            cell.transform = CGAffineTransform(translationX: -10, y: 0)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                cell.transform = CGAffineTransform.identity
            } completion: { _ in
                if self.selectedRows.isEmpty {
                    self.cancelEditing()
                } else {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    private func deleteSelectedRows() {
        let sortedSelectedRows = selectedRows.sorted(by: >)
        for indexPathRow in sortedSelectedRows {
            tasks.remove(at: indexPathRow)
        }
        selectedRows.removeAll()
        tableView.reloadData()
    }
    
    @objc private func deleteButtonTapped() {
        deleteSelectedRows()
        cancelEditing()
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


