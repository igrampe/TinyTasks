//
//  MainViewController.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 30.10.2021.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    var databaseService: DatabaseService?
    private var tableController = TableController<TaskList, TaskListCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableController.loadData()
    }
    
    // MARK: - UI
    
    private func setupView() {
        title = "Tiny Tasks"
        
        tableView.register(TaskListCell.self, forCellReuseIdentifier: NSStringFromClass(TaskListCell.self))
        if let databaseService = databaseService {
            tableController.setup(with: tableView, context: databaseService.mainContext, sortDescriptorKey: "creationDate")
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
        let vc = NewTaskListViewController()
        vc.databaseService = databaseService
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
        guard let objectID = tableController.objectID(at: indexPath.row) else {
            return
        }
        let vc = TaskListViewController()
        vc.databaseService = databaseService
        vc.taskListObjectID = objectID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.handleDeleteAction(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
