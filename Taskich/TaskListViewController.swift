//
//  TaskListViewController.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 20.09.2023.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        navigationItem.title = "Taskich"
        
        let addTaskButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(addTask))
        addTaskButton.tintColor = .black
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else { fatalError() }
        
        cell.configure(task: tasks[indexPath.row])
        
        return cell
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
}
