//
//  TaskListViewController.swift.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    var databaseService: DatabaseService?
    var taskListObjectID: NSManagedObjectID?
    private var tableController = TableController<Task, TaskCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableController.loadData()
    }
    
    // MARK: - UI
    
    private func setupView() {        
        tableView.register(TaskCell.self, forCellReuseIdentifier: NSStringFromClass(TaskCell.self))
        if let context = databaseService?.mainContext,
           let taskListObjectID = taskListObjectID,
           let taskList: TaskList = try? context.existingObject(with: taskListObjectID) as? TaskList {
            title = taskList.title
            let predicate = NSPredicate(format: "list == %@", taskList)
            tableController.setup(with: tableView, context: context, sortDescriptorKey: "creationDate", predicate: predicate)
        }
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddList))
        navigationItem.rightBarButtonItem = addItem
    }
    
    // MARK: - Actions
    
    @objc
    private func actionAddList() {
        let vc = NewTaskViewController()
        vc.databaseService = databaseService
        vc.taskListObjectID = taskListObjectID
        let navigationController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func handleDeleteAction(at indexPath: IndexPath) {
        guard let objectID = tableController.objectID(at: indexPath.row) else {
            return
        }
        databaseService?.deleteObject(with: objectID)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let object = tableController.object(at: indexPath.row) else {
            return
        }
        object.completed = !object.completed
        databaseService?.saveMainContext()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.handleDeleteAction(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
