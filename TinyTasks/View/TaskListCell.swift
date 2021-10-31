//
//  TaskListCell.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit

class TaskListCell: UITableViewCell, ConfigurableCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    private func setupView() {
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with object: Any) {
        guard let object = object as? TaskList else {
            fatalError("Object should be TaskList")
        }
        textLabel?.text = object.title
    }
}
