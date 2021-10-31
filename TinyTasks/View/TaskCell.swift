//
//  TaskCell.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit

class TaskCell: UITableViewCell, ConfigurableCell {
    func configure(with object: Any) {
        guard let object = object as? Task else {
            fatalError("Object should be Task")
        }
        textLabel?.text = object.title
        accessoryType = object.completed ? .checkmark : .none
    }
}
