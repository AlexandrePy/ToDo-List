//
//  TaskTableViewController.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import CoreData
import os.log

class TaskTableViewController: UITableViewController, CheckButtonPressedDelegate {

    //MARK: Properties
    
    var list: NSManagedObject!
    var tasks: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller
        setToolbarItems([editButtonItem], animated: true)
        
        navigationItem.title = list.value(forKey: "eName") as? String
        
        fetchTasks()
        
        if tasks.isEmpty {
            loadSampleTasks()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // We fetch the task of the corresponding list
        fetchTasks()
        
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
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifer = "TaskTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath) as? TaskTableViewCell else {
            fatalError("The dequeued cell is not an instance of TaskTableViewCell")
        }

        // Fetches the appropriate task for the data source layout
        let task = tasks[indexPath.row]
        
        cell.nameLabel.text = task.value(forKey: "eName") as? String
        cell.checkButton.isSelected = (task.value(forKey: "eState") as? Bool)!
        
        // Handle the user's tap on checkButton through delegate callbacks
        cell.delegate = self
        
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
            removeTask(pos: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*// Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new task.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            
            guard let taskDetailViewController = segue.destination as? TaskViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTaskCell = sender as? TaskTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTaskCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selT = tasks[indexPath.row]
            let selectedTask = Task(aName: selT.value(forKey: "eName") as! String, aDescription: selT.value(forKey: "eDescription") as! String?, aState: (selT.value(forKey: "eState") as? Bool)!)
            taskDetailViewController.task = selectedTask
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
        
    }
    
    //MARK: CheckButtonPressedDelegate
    
    func userDidTapCheckButton(_ sender: TaskTableViewCell) {
        
        let selectedIndexPath = tableView.indexPath(for: sender)
        
        // We update the state of the task
        let bState = !(tasks[(selectedIndexPath?.row)!].value(forKey: "eState") as! Bool)
        updateTask(eState: bState, pos: (selectedIndexPath?.row)!)
        
        tableView.reloadData()
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing task
                self.updateTask(eName: task.myName, eDescription: task.myDescription, pos: selectedIndexPath.row)
                
            } else {
                
                // Add a new task
                self.addTask(eName: task.myName, eDescription: task.myDescription, eState: task.myState, eMyEntity: list.value(forKey: "eName") as! String)
                
            }
            
            tableView.reloadData()
      
        }
        
    }
    
    
    //MARK: Private Methods
    
    
    // Used to a new task and save it
    private func addTask(eName: String, eDescription: String?, eState: Bool, eMyEntity: String) {
        
        print("-- saving task: \(eName) --")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We create a new List entity
        let entity = NSEntityDescription.entity(forEntityName: "CDTask", in: managedContext)!
        
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // We set its values
        task.setValue(eName, forKeyPath: "eName")
        task.setValue(eDescription, forKeyPath: "eDescription")
        task.setValue(eState, forKeyPath: "eState")
        task.setValue(eMyEntity, forKey: "eMyEntity")
        
        // We test if everything went well and add the new list to the lists
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("---------------")
    }
    
    
    // Used to update an already existing task and save the changes
    func updateTask(eName: String, eDescription: String?, pos: Int) {
        
        print("-- updating task: \(eName)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We update the values that changed
        tasks[pos].setValue(eName, forKey: "eName")
        tasks[pos].setValue(eDescription, forKey: "eDescription")
        
        // We test if everything went well and save the changes to the list
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("---------------")
    }
    
    // Used to update the state of a task when the check button is tapped
    func updateTask(eState: Bool, pos: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We update the state
        tasks[pos].setValue(eState, forKey: "eState")
        
        // We test if everything went well and save the changes to the list
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // Used to remove a task from the list
    func removeTask(pos: Int) {
        
        print("-- removing task: \(tasks[pos].value(forKey: "eName") as? String) --")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // We test if everything went well and remove the list at pos from the lists
        do {
            managedContext.delete(tasks.remove(at: pos))
            try managedContext.save()
        } catch let error as NSError {
            print("Could not remove task: \(tasks[pos].value(forKey: "eName")). \(error), \(error.userInfo)")
        }
        
        print("---------------")
        
    }
    
    // Used to fetch all the tasks of a given list, done everytime we arrive on this view
    func fetchTasks() {
        
        print("-- fetching tasks --")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // We get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDTask")
        
            // Predicate
        let predicate = NSPredicate(format: "%K == %@", "eMyEntity", list.value(forKey: "eName") as! String)
        fetchRequest.predicate = predicate
        
        // We test if everything went well and get the lists
        do {
            tasks = try managedContext.fetch(fetchRequest)
            for task in tasks {
                if let name = task.value(forKey: "eName"), let desc = task.value(forKey: "eDescription"), let entty = task.value(forKey: "eMyEntity") {
                    print("\(name) / \(desc) / \(entty)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        print("----------------")
    }
    
    private func loadSampleTasks() {
    
        if (list.value(forKey: "eName") as? String) == "Groceries" {
            addTask(eName: "Eggs", eDescription: "Buy 10 farm eggs", eState: false, eMyEntity: "Groceries")
            addTask(eName: "Milk", eDescription: "Buy 3 galleons of whole milk", eState: false, eMyEntity: "Groceries")
            addTask(eName: "Peanut butter", eDescription: "Buy 2 jars", eState: false, eMyEntity: "Groceries")
        } else if (list.value(forKey: "eName") as? String) == "Trip to Boston" {
            addTask(eName: "Buy plane tickets", eDescription: "From the 18/02 to the 25/02", eState: false, eMyEntity: "Trip to Boston")
            addTask(eName: "Book hotel room", eDescription: "At the Mandarin Oriental, for two, on the 22nd", eState: false, eMyEntity: "Trip to Boston")
        }
        
    }
 
}
