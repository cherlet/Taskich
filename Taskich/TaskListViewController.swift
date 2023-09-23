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
        
        let addTaskButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(addTask))
        
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
    @objc func addTask() {
        let alertController = UIAlertController(title: "Добавить задачу", message: nil, preferredStyle: .alert)
        
        alertController.addTextField()
        
        let addAction = UIAlertAction(title: "+", style: .default) { [weak self] _ in
            if let taskText = alertController.textFields?.first?.text, !taskText.isEmpty {
                let newTask = Task(label: taskText, isCompleted: false)
                self?.tasks.append(newTask)
                
                self?.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "-", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
