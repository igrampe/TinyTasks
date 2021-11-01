//
//  UITableViewCell+ConfigurableCell.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit

protocol ConfigurableCell: UITableViewCell {
    func configure(with object: Any)
}
