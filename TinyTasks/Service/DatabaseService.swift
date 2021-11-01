//
//  DatabaseService.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import Foundation
import CoreData

class DatabaseService {    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TinyTasks")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func saveContext(_ context: NSManagedObjectContext, needReset: Bool = false) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Save context \(nsError), \(nsError.userInfo)")
            }
            if needReset {
                context.reset()
            }
        }
    }

    // MARK: - Public
    
    func addTaskList(with title: String?) {
        persistentContainer.performBackgroundTask { [weak self] taskContext in
            taskContext.automaticallyMergesChangesFromParent = true
            
            let taskList = TaskList(context: taskContext)
            do {
                try taskContext.obtainPermanentIDs(for: [taskList])
            } catch {
                print(error)
            }
            
            taskList.creationDate = Date()
            taskList.title = title
            
            self?.saveContext(taskContext, needReset: true)
        }
    }
    
    func addTask(with title: String?, taskListObjectID: NSManagedObjectID?) {
        guard let taskListObjectID = taskListObjectID else {
            return
        }
        
        persistentContainer.performBackgroundTask { [weak self] taskContext in
            taskContext.automaticallyMergesChangesFromParent = true
            
            guard let taskList = try? taskContext.existingObject(with: taskListObjectID) as? TaskList else {
                taskContext.reset()
                return
            }
            
            let task = Task(context: taskContext)
            do {
                try taskContext.obtainPermanentIDs(for: [task])
            } catch {
                print(error)
            }
            
            task.creationDate = Date()
            task.title = title
            task.completed = false
            
            taskList.addToTasks(task)
            
            self?.saveContext(taskContext, needReset: true)
        }
    }
    
    func toggleTaskCompletion(with objectID: NSManagedObjectID) {
        persistentContainer.performBackgroundTask { [weak self] taskContext in
            taskContext.automaticallyMergesChangesFromParent = true
            
            guard let object = try? taskContext.existingObject(with: objectID) as? Task else {
                taskContext.reset()
                return
            }
            object.completed = !object.completed
            
            self?.saveContext(taskContext, needReset: true)
        }
    }
    
    func deleteObject(with objectID: NSManagedObjectID) {
        persistentContainer.performBackgroundTask { [weak self] taskContext in
            taskContext.automaticallyMergesChangesFromParent = true
            
            guard let object = try? taskContext.existingObject(with: objectID) else {
                taskContext.reset()
                return
            }
            taskContext.delete(object)
            
            self?.saveContext(taskContext, needReset: true)
        }
    }
}
