//
//  ListTableViewController.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 11/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import CoreData
import os.log

class ListTableViewController: UITableViewController {

    //MARK: Properties
    var lists: [NSManagedObject] = []
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bottom bar
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.barTintColor =  UIColor(red: 94.0/255.0, green: 156.0/255.0, blue: 118.0/255.0, alpha: 255.0)
        navigationController?.toolbar.tintColor = UIColor.white
        // Use the edit button item provided by the table view controller
        setToolbarItems([editButtonItem], animated: true)
        
        fetchLists()
        
        if lists.isEmpty {
            loadSampleLists()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "ListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListTableViewCell")
        }
        
        // Fetches the appropriate list from the data source layout
        let list = lists[indexPath.row]
        
        cell.nameLabel.text = list.value(forKeyPath: "eName") as? String

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            removeList(pos: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        
        case "ViewList":
            
            guard let listDetailViewController = segue.destination as? TaskTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedListCell = sender as? ListTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedListCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedList = lists[indexPath.row]
            listDetailViewController.list = selectedList
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
    //MARK: Actions
    
    @IBAction func addList(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New List", message: "Add a new list",preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self.addNewList(eName: nameToSave)
            self.myTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)

        alert.view.tintColor = UIColor(red: 94.0/255.0, green: 156.0/255.0, blue: 118.0/255.0, alpha: 255.0)
        
    }
    
    
    //MARK: Private Methods
    
    // Used to add a new list of to-dos to the already existing lists
    func addNewList(eName: String) {
        
        print("-- saving list: \(eName)--")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We create a new List entity
        let entity = NSEntityDescription.entity(forEntityName: "CDList", in: managedContext)!
        
        let list = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // We set its value
        list.setValue(eName, forKey: "eName")
        
        // We test if everything went well and add the new list to the lists
        do {
            try managedContext.save()
            lists.append(list)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("---------------")
    }
    
    // Used to remove a list of to-dos and all the tasks of the said list
    func removeList(pos: Int) {
        
        print("-- removing: list \(lists[pos].value(forKey: "eName") as? String) --")
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We first remove all the tasks
        
            // Fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDTask")
        
                // Predicate
        let predicate = NSPredicate(format: "%K == %@", "eMyEntity", lists[pos].value(forKey: "eName") as! String)
        fetchRequest.predicate = predicate
        
                // We fetch the tasks to remove
        var tasks: [NSManagedObject] = []
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch tasks from \(lists[pos].value(forKey: "eName")). \(error), \(error.userInfo)")
        }
        
            // We remove them
        do {
            for task in tasks {
                managedContext.delete(task)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not remove tasks from \(lists[pos].value(forKey: "eName")). \(error), \(error.userInfo)")
        }
        
        // We then remove list at row pos from the lists
        do {
            managedContext.delete(lists.remove(at: pos))
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        print("---------------")
        
    }
    
    // Used to fetch all the already existing lists
    func fetchLists() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We send a fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDList")
        
        // We test if everything went well and get the lists
        do {
            print("-- fetching lists --")
            lists = try managedContext.fetch(fetchRequest)
            for list in lists {
                if let name = list.value(forKey: "eName") {
                    print("\(name)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("---------------")
    }
    
    private func loadSampleLists() {
        
        // Groceries
        self.addNewList(eName: "Groceries")
        
        
        // Travel
        self.addNewList(eName: "Trip to Boston")

        
    }
    
}
