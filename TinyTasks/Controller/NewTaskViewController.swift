//
//  NewTaskViewController.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit
import CoreData

class NewTaskViewController: UIViewController {
    private var textField = UITextField()
    
    var databaseService: DatabaseService?
    var taskListObjectID: NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        textField.becomeFirstResponder()
    }
    
    // MARK: - UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "New Task"
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Task Name"
        view.addSubview(textField)
        
        setupNavigationBar()
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func setupNavigationBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))
        navigationItem.rightBarButtonItem = doneItem
        
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(actionClose))
        navigationItem.leftBarButtonItem = closeItem
    }
    
    // MARK: - Actions
    
    @objc
    private func actionDone() {
        save()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func actionClose() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Logic
    
    private func save() {
        var title = textField.text
        if title?.count ?? 0 == 0 {
            title = "Unnamed task"
        }
        databaseService?.addTask(with: title, taskListObjectID: taskListObjectID)
    }
}
