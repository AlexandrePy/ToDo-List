//
//  TaskTableViewController.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import os.log

class TaskTableViewController: UITableViewController, CheckButtonPressedDelegate {

    //MARK: Properties
    
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Handle the user's tap on checkButton through delegate callbacks
        
        // Load any saved tasks, otherwise load sample data
        if let savedTasks = loadTasks() {
            tasks += savedTasks
        } else {
            // Load sample data
            loadSampleTasks()
        }
    
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
        
        cell.nameLabel.text = task.myName
        cell.checkButton.isSelected = task.myState
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
            tasks.remove(at: indexPath.row)
            saveTasks()
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
            
            let selectedTask = tasks[indexPath.row]
            taskDetailViewController.task = selectedTask
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
        
    }
    
    //MARK: CheckButtonPressedDelegate
    
    func userDidTapCheckButton(_ sender: TaskTableViewCell) {
        let selectedIndexPath = tableView.indexPath(for: sender)
        tasks[(selectedIndexPath?.row)!].myState = !tasks[(selectedIndexPath?.row)!].myState
        tableView.reloadRows(at: [selectedIndexPath!], with: .none)
        saveTasks()
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing task
                tasks[selectedIndexPath.row] = task
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                
                // Add a new task
                let newIndexPath = IndexPath(row: tasks.count,section:0)
                tasks.append(task)
                tableView.insertRows(at: [newIndexPath], with: .automatic)

            }
            
            // Save the tasks
            saveTasks()
      
        }
        
    }
    
    //MARK: Private Methods
    
    private func loadSampleTasks() {
        
        guard let task1 = Task(aName: "Eggs", aDescription: "buy 10 farm eggs", aState: false) else {
            fatalError("Unable to instantiate task1")
        }
    
        guard let task2 = Task(aName: "Milk", aDescription: "buy 10 Galleons of whole milk", aState: false) else {
            fatalError("Unable to instantiate task2")
        }
        
        guard let task3 = Task(aName: "Coffee", aDescription: "buy 2 boxes of Colombian coffee", aState: false) else {
            fatalError("Unable to instantiate task3")
        }
        
        tasks += [task1,task2,task3]
        
    }
    
    private func saveTasks() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks", log: OSLog.default, type: .debug)
        }
        
    }
    
    private func loadTasks() -> [Task]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURL.path) as? [Task]
    }

}
