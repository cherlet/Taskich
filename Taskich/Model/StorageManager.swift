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
    
    public func createTask(text: String, date: Date) {
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        let task = Taska(entity: taskEntity, insertInto: context)
        task.id = UUID()
        task.text = text
        task.date = date
        task.isCompleted = false
        
        appDelegate.saveContext()
    }
    
    public func fetchTasks() -> [Taska] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            return (try? context.fetch(fetchRequest) as? [Taska]) ?? []
        }
    }
    
    public func fetchTask(with id: UUID) -> Taska? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tasks = try? context.fetch(fetchRequest) as? [Taska]
            return tasks?.first
        }
    }
    
    public func updateTask(with id: UUID, newText: String?, newDate: Date?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Taska],
                  let task = tasks.first else { return }
            
            if let newText = newText {
                task.text = newText
            }
            if let newDate = newDate {
                task.date = newDate
            }
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTasks() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            let tasks = try? context.fetch(fetchRequest) as? [Taska]
            tasks?.forEach { context.delete($0) }
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTask(with id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Taska],
                  let task = tasks.first else { return }
            context.delete(task)
        }
        
        appDelegate.saveContext()
    }

}
