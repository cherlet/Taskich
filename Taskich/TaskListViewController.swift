//
//  TaskListViewController.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 20.09.2023.
//

import UIKit

class TaskListViewController: UITableViewController {

    var tasks = Task.makeTasks()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
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
}
