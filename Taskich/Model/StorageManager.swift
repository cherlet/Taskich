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
    
    // MARK: - Task Methods
    
    public func createTask(text: String, date: Date, tag: Tag) {
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        let task = Task(entity: taskEntity, insertInto: context)
        task.id = UUID()
        task.text = text
        task.date = date
        task.tag = tag
        task.reminder = nil
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
    
    public func fetchTasksGroupedBySections() -> [[Task]] {
        let allTasks = fetchCurrentTasks()
        let calendar = Calendar.current

        let todayTasks = allTasks.filter {
            calendar.isDateInToday($0.date ?? Date())
        }
        let tomorrowTasks = allTasks.filter {
            calendar.isDateInTomorrow($0.date ?? Date())
        }
        let weekTasks = allTasks.filter {
            guard let date = $0.date else { return false }
            return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) &&
                   !calendar.isDateInToday(date) && !calendar.isDateInTomorrow(date)
        }
        let futureTasks = allTasks.filter {
            guard let date = $0.date else { return true }
            return !calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        }

        return [todayTasks, tomorrowTasks, weekTasks, futureTasks]
    }
    
    public func updateTask(with id: UUID,
                           newText: String? = nil,
                           newDate: Date? = nil,
                           newReminder: Date? = nil,
                           newTag: Tag? = nil) {
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
            if let newTag = newTag {
                task.tag = newTag
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
    
    // MARK: - Tag Methods
    
    public func fillDefaultTags() {
        let defaults = UserDefaults.standard
        let defaultTagsKey = "hasFilledDefaultTags"
        
        if !defaults.bool(forKey: defaultTagsKey) {
            guard let tagEntity = NSEntityDescription.entity(forEntityName: "Tag", in: context) else {
                return
            }
            
            let defaultTags = ["Работа": "BlueColor",
                               "Учеба": "GreenColor",
                               "Спорт": "RedColor",
                               "Дом": "PurpleColor",
                               "Покупки": "YellowColor"]

            for (tagName, tagColor) in defaultTags {
                let newTag = Tag(entity: tagEntity, insertInto: context)
                newTag.id = UUID()
                newTag.name = tagName
                newTag.color = tagColor
            }
            
            appDelegate.saveContext()
            
            defaults.set(true, forKey: defaultTagsKey)
        }
    }
    
    public func createTag(name: String, color: String) {
        guard let tagEntity = NSEntityDescription.entity(forEntityName: "Tag", in: context) else {
            return
        }
        
        let tag = Tag(entity: tagEntity, insertInto: context)
        tag.id = UUID()
        tag.name = name
        tag.color = color
        
        appDelegate.saveContext()
    }
    
    public func fetchTags() -> [Tag] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        
        do {
            return (try? context.fetch(fetchRequest) as? [Tag]) ?? []
        }
    }
    
    public func fetchTag(with id: UUID) -> Tag? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tags = try? context.fetch(fetchRequest) as? [Tag]
            return tags?.first
        }
    }
    
    public func updateTag(with id: UUID, newName: String? = nil, newColor: String? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tags = try? context.fetch(fetchRequest) as? [Tag],
                  let tag = tags.first else { return }
            
            if let newName = newName {
                tag.name = newName
            }
            if let newColor = newColor {
                tag.color = newColor
            }
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTags() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        
        do {
            let tags = try? context.fetch(fetchRequest) as? [Tag]
            tags?.forEach { context.delete($0) }
        }
        
        appDelegate.saveContext()
    }
    
    public func deleteTag(with id: UUID, replaceWith newTag: Tag? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let tasksFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        tasksFetchRequest.predicate = NSPredicate(format: "tag.id == %@", id as CVarArg)
        
        do {
            guard let tasks = try? context.fetch(tasksFetchRequest) as? [Task]
            else { return }
            
            if let replacementTag = newTag {
                for task in tasks {
                    task.tag = replacementTag
                }
            } else {
                for task in tasks {
                    context.delete(task)
                }
            }
            
            guard let tags = try? context.fetch(fetchRequest) as? [Tag],
                  let tag = tags.first else { return }
            context.delete(tag)
        }
        
        appDelegate.saveContext()
    }
}
