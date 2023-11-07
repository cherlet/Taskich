import UIKit
import CoreData

public final class StorageManager {
    public static let shared = StorageManager()
    private init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func createTask(text: String, date: Date, reminder: Date? = nil) {
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        let task = Task(entity: taskEntity, insertInto: context)
        task.id = UUID()
        task.text = text
        task.date = date
        task.reminder = reminder
        task.isCompleted = false
        task.isInTrash = false
        
        appDelegate.saveContext()
    }
    
    public func fetchTasks() -> [Task] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            return (try? context.fetch(fetchRequest) as? [Task]) ?? []
        }
    }
    
    public func fetchCurrentTasks() -> [Task] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isCompleted == %@", NSNumber(value: false)),
            NSPredicate(format: "isInTrash == %@", NSNumber(value: false))
        ])
        
        do {
            return (try? context.fetch(fetchRequest) as? [Task]) ?? []
        }
    }
    
    public func fetchArchivedTasks() -> [Task] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isCompleted == %@", NSNumber(value: true)),
            NSPredicate(format: "isInTrash == %@", NSNumber(value: false))
        ])
        
        do {
            return (try? context.fetch(fetchRequest) as? [Task]) ?? []
        }
    }
    
    public func fetchTrashTasks() -> [Task] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "isInTrash == %@", NSNumber(value: true))
        
        do {
            return (try? context.fetch(fetchRequest) as? [Task]) ?? []
        }
    }
    
    public func fetchTask(with id: UUID) -> Task? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tasks = try? context.fetch(fetchRequest) as? [Task]
            return tasks?.first
        }
    }
    
    public func updateTask(with id: UUID, newText: String?, newDate: Date?, newReminder: Date?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            
            if let newText = newText {
                task.text = newText
            }
            if let newDate = newDate {
                task.date = newDate
            }
            
            task.reminder = newReminder
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTasks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            let tasks = try? context.fetch(fetchRequest) as? [Task]
            tasks?.forEach { context.delete($0) }
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTask(with id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            context.delete(task)
        }
        
        appDelegate.saveContext()
    }
    
    public func moveToArchive(task id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            task.isCompleted = true
        }
        
        appDelegate.saveContext()
    }
    
    public func returnFromArchive(task id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            task.isCompleted = false
        }
        
        appDelegate.saveContext()
    }
    
    public func moveToTrash(task id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            task.isInTrash = true
        }
        
        appDelegate.saveContext()
    }
    
    public func returnFromTrash(task id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let task = tasks.first else { return }
            task.isInTrash = false
        }
        
        appDelegate.saveContext()
    }
}
