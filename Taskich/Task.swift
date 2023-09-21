//
//  Task.swift
//  Taskich
//
//  Created by Усман Махмутхажиев on 20.09.2023.
//

struct Task {
    var label: String
    var isCompleted: Bool
    
    static func makeTasks() -> [Task] {
        [Task(label: "111", isCompleted: false),
         Task(label: "222", isCompleted: false),
         Task(label: "333", isCompleted: false),
         Task(label: "444", isCompleted: false),
         Task(label: "555", isCompleted: false)]
    }
}


