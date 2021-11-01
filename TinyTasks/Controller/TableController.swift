//
//  TableController.swift
//  TinyTasks
//
//  Created by Semyon Belokovsky on 31.10.2021.
//

import UIKit
import CoreData

class TableController <Model: NSManagedObject, Cell: ConfigurableCell> : NSObject, NSFetchedResultsControllerDelegate {
    private var tableView: UITableView?
    private var dataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID>?
    private var context: NSManagedObjectContext?
    private var fetchController: NSFetchedResultsController<NSFetchRequestResult>?
    
    func setup(with tableView: UITableView, context: NSManagedObjectContext, sortDescriptorKey: String, predicate: NSPredicate? = nil) {
        self.tableView = tableView
        self.context = context
        setupDataSource()
        setupFetchedController(with: sortDescriptorKey, predicate: predicate)
    }
    
    private func setupDataSource() {
        guard let tableView = tableView else {
            return
        }
        guard let context = context else {
            return
        }
        
        dataSource = UITableViewDiffableDataSource<Int, NSManagedObjectID>(tableView: tableView, cellProvider: { tableView, indexPath, objectID in
            guard let object = try? context.existingObject(with: objectID) else {
                fatalError("Managed object should be available")
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Cell.self), for: indexPath) as? Cell else {
                return UITableViewCell()
            }
            cell.configure(with: object)
            return cell
        })
        tableView.dataSource = dataSource
    }
    
    private func setupFetchedController(with sortDescriptorKey: String, predicate: NSPredicate?) {
        guard let context = context else {
            fatalError("Context should be available")
        }
        let fetchRequest = Model.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortDescriptorKey, ascending: false)]
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchController?.delegate = self
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        dataSource?.apply(snapshot, animatingDifferences: tableView?.window != nil)
    }
    
    // MARK: - Public
    
    func loadData() {
        guard let fetchController = fetchController else {
            fatalError("Fetch controller should be available")
        }

        do {
            try fetchController.performFetch()
        } catch {
            print(error)
        }
    }
    
    func objectID(at index: Int) -> NSManagedObjectID? {
        guard let dataSource = dataSource else {
            fatalError("Datasource should be available")
        }
        let snapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        guard snapshot.numberOfItems > index else {
            return nil
        }
        return snapshot.itemIdentifiers[index]
    }
}
