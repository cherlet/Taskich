import UIKit

protocol TaskListViewControllerDelegate: AnyObject {
    func didTapMenuButton()
    func closeMenu()
}

class TaskListViewController: UITableViewController,  UITableViewDragDelegate, UITableViewDropDelegate {
    
    var tasks = [[Task]]()
    var tags = [Tag]()
    var isEditingMode = false
    var selectedRows = Set<IndexPath>()
    var editModeToolbar = EditModeToolbarView()
    weak var delegate: TaskListViewControllerDelegate?
    var editModeToolbarBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(swipeOpenMenu)
        view.addGestureRecognizer(swipeCloseMenu)
        //view.addGestureRecognizer(tapCloseMenu)
        setupTableView()
        setupNavigationBar()
        setupEditModeToolbar()
        updateData()
        updateTagData()
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
            let cancelTaskButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(cancelEditing))
            cancelTaskButton.tintColor = .black
            navigationItem.rightBarButtonItem = cancelTaskButton
        } else {
            let addTaskButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(addTask))
            addTaskButton.tintColor = .black
            navigationItem.rightBarButtonItem = addTaskButton
        }
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"),
                                         style: .done,
                                         target: self,
                                         action: #selector(didTapMenuButton))
        menuButton.tintColor = .black
        navigationItem.leftBarButtonItem = menuButton
    }
    
    private func setupEditModeToolbar() {
        view.addSubview(editModeToolbar)
        editModeToolbar.isHidden = true
        editModeToolbarBottomConstraint = editModeToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 100)
        
        
        editModeToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editModeToolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editModeToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            editModeToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            editModeToolbarBottomConstraint
        ])
        
        editModeToolbar.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editModeToolbar.dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Core Data
    func updateData() {
        tasks = StorageManager.shared.fetchTasksGroupedBySections()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateTagData() {
        tags = StorageManager.shared.fetchTags()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TaskSection(rawValue: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Config reusable cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            fatalError()
        }
        cell.delegate = self
        
        // Swipe gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeGestureRecognizer(_:)))
        swipeLeftGesture.direction = .left
        cell.addGestureRecognizer(swipeLeftGesture)
        
        // TaskCell.configure
        cell.configure(task: tasks[indexPath.section][indexPath.row])
        
        // Design for editingMode
        if selectedRows.contains(indexPath) {
            cell.selectedBackground.isHidden = false
        } else {
            cell.selectedBackground.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            if selectedRows.contains(indexPath) {
                selectedRows.remove(indexPath)
            } else {
                selectedRows.insert(indexPath)
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
        
        let newDate: Date
        switch destinationIndexPath.section {
        case 0:
            newDate = taskDates.today
        case 1:
            newDate = taskDates.tomorrow
        case 2:
            newDate = taskDates.onWeek
        default:
            newDate = taskDates.nextWeek
        }
        
        if sourceIndexPath.section != destinationIndexPath.section {
            tasks[sourceIndexPath.section][sourceIndexPath.row].date = newDate
            let movedTask = tasks[sourceIndexPath.section].remove(at: sourceIndexPath.row)
            tasks[destinationIndexPath.section].insert(movedTask, at: destinationIndexPath.row)
        } else {
            let movedTask = tasks[sourceIndexPath.section].remove(at: sourceIndexPath.row)
            tasks[destinationIndexPath.section].insert(movedTask, at: destinationIndexPath.row)
        }
    }
    
    // MARK: - Drag&Drop protocol
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let task = tasks[indexPath.section][indexPath.row]
        let itemProvider = NSItemProvider(object: task.text! as NSString)
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
            guard let stringItems = items as? [String], let taskLabel = stringItems.first else { return }
            
            for (sectionIndex, section) in self.tasks.enumerated() {
                if let rowIndex = section.firstIndex(where: { $0.text == taskLabel }) {
                    let movedTask = self.tasks[sectionIndex].remove(at: rowIndex)
                    self.tasks[destinationIndexPath.section].insert(movedTask, at: destinationIndexPath.row)
                    tableView.reloadData()
                    break
                }
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
        
        addFormController.onAddButtonTapped = { taskText, date, tag in
            if !taskText.isEmpty {
                StorageManager.shared.createTask(text: taskText, date: date, tag: tag)
                self.updateData()
            }
        }
    }
    
    private func presentTask(at indexPath: IndexPath) {
        let presenterViewController = TaskPresenterViewController()
        presenterViewController.modalPresentationStyle = .formSheet
        
        presenterViewController.taskText = tasks[indexPath.section][indexPath.row].text
        presenterViewController.taskDate = tasks[indexPath.section][indexPath.row].date
        presenterViewController.taskReminder = tasks[indexPath.section][indexPath.row].reminder
        presenterViewController.tag = tasks[indexPath.section][indexPath.row].tag
        
        let taskID = tasks[indexPath.section][indexPath.row].id
        let tempReminder = tasks[indexPath.section][indexPath.row].reminder
        
        presenterViewController.onTaskTextUpdate = { text, date, reminder, tag in
            StorageManager.shared.updateTask(with: taskID, newText: text, newDate: date, newReminder: reminder, newTag: tag)
            self.updateData()
            
            guard let tempTask = StorageManager.shared.fetchTask(with: taskID) else { return }
            self.configureNotification(previousReminder: tempReminder, task: tempTask)
        }
        
        present(presenterViewController, animated: true)
    }
    
    @objc private func didTapMenuButton() {
        delegate?.didTapMenuButton()
    }
    
    @objc private func closeMenu() {
        delegate?.closeMenu()
    }
    
    private lazy var swipeOpenMenu: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didTapMenuButton))
        gestureRecognizer.direction = .right
        return gestureRecognizer
    }()
    
    private lazy var swipeCloseMenu: UISwipeGestureRecognizer = {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeMenu))
        gestureRecognizer.direction = .left
        return gestureRecognizer
    }()
    
    private lazy var tapCloseMenu: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        return tapGesture
    }()
    
    // MARK: - Other Methods
    private func configureNotification(previousReminder: Date?, task: Task) {
        if previousReminder == nil && task.reminder != nil {
            NotificationManager.shared.createNotification(for: task)
        } else if previousReminder != nil && task.reminder == nil {
            NotificationManager.shared.deleteNotification(with: task.id)
        } else {
            NotificationManager.shared.updateNotification(in: task)
        }
    }
    
    @objc private func leftSwipeGestureRecognizer(_ gesture: UISwipeGestureRecognizer) {
        
        guard let indexPath = tableView.indexPathForRow(at: gesture.location(in: tableView)),
              let cell = tableView.cellForRow(at: indexPath)
        else {
            return
        }
        
        isEditingMode = true
        showEditModeToolbar()
        setupNavigationBar()
        
        if selectedRows.contains(indexPath) {
            selectedRows.remove(indexPath)
        } else {
            selectedRows.insert(indexPath)
        }
        
        leftSwipeGestureAnimation(for: cell, at: indexPath)
    }
    
    @objc private func cancelEditing() {
        isEditingMode = false
        hideEditModeToolbar()
        selectedRows.removeAll()
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
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func deleteSelectedRows() {
        let sortedSelectedRows = selectedRows.sorted { $0.section > $1.section || ($0.section == $1.section && $0.row > $1.row) }
        var indexPathsToDelete: [IndexPath] = []
        
        for indexPath in sortedSelectedRows {
            let deletedTask = tasks[indexPath.section].remove(at: indexPath.row)
            StorageManager.shared.moveToTrash(task: deletedTask.id)
            indexPathsToDelete.append(indexPath)
            
            if let navigationController = parent as? UINavigationController,
               let containerVC = navigationController.parent as? ContainerViewController {
                containerVC.updateTrash()
            }
        }
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        tableView.endUpdates()
        
        selectedRows.removeAll()
        tableView.reloadData()
    }
    
    
    @objc private func deleteButtonTapped() {
        deleteSelectedRows()
        cancelEditing()
    }
    
    private func changeDateSelectedRows(with date: Date) {
        for indexPath in selectedRows.sorted(by: { $0.section > $1.section || ($0.section == $1.section && $0.row > $1.row) }) {
            let taskToChange = tasks[indexPath.section][indexPath.row]
            StorageManager.shared.updateTask(with: taskToChange.id, newText: nil, newDate: date, newReminder: nil)
        }
        
        updateData()
        cancelEditing()
    }
    
    
    @objc private func dateButtonTapped() {
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.modalPresentationStyle = .overFullScreen
        datePickerViewController.appear(sender: self)
        datePickerViewController.onDateSelected = { [weak self] selectedDate in
            self?.changeDateSelectedRows(with: selectedDate)
        }
    }
    
    
    private func showEditModeToolbar() {
        editModeToolbar.isHidden = false
        editModeToolbarBottomConstraint.constant = -24
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func hideEditModeToolbar() {
        editModeToolbarBottomConstraint.constant = 100
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.editModeToolbar.isHidden = true
        }
    }
}

extension TaskListViewController: TaskCellDelegate {
    func archived(_ cell: TaskCell, didCompleteTask task: Task) {
        for (sectionIndex, section) in tasks.enumerated() {
            if let rowIndex = section.firstIndex(where: { $0.text == task.text && $0.date == task.date }) {
                let archivedTask = tasks[sectionIndex].remove(at: rowIndex)
                StorageManager.shared.moveToArchive(task: archivedTask.id)
                updateData()
                
                if let navigationController = parent as? UINavigationController,
                   let containerVC = navigationController.parent as? ContainerViewController {
                    containerVC.updateArchive()
                }
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .right)
                tableView.endUpdates()
                break
            }
        }
    }
    
    func unarchived(_ cell: TaskCell, didUnarchivedTask task: Task) {
        //
    }
}

extension TaskListViewController {
    enum TaskSection: Int, CaseIterable {
        case today
        case tomorrow
        case week
        case future
        
        var title: String {
            switch self {
            case .today: return "Сегодня"
            case .tomorrow: return "Завтра"
            case .week: return "На неделе"
            case .future: return "Потом"
            }
        }
    }
    
    struct TaskDates {
        let today: Date
        let tomorrow: Date
        let onWeek: Date
        let nextWeek: Date
    }
    
    var taskDates: TaskDates {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today),
              let onWeek = calendar.date(byAdding: .day, value: 2, to: today),
              let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today) else {
            fatalError("Не удалось вычислить даты.")
        }
        return TaskDates(today: today, tomorrow: tomorrow, onWeek: onWeek, nextWeek: nextWeek)
    }
}





