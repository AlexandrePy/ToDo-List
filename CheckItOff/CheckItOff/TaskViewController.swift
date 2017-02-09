//
//  TaskViewController.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import os.log

class TaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `TaskTableViewController`in `prepare(for:sender:)`or constructed as part of adding a new task
     */
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks
        nameTextField.delegate = self
        
        // Handle the text view's user input through delegate callbacks
        descriptionTextView.delegate = self
        
        // Set up views if editing an existing Task
        if let task = task {
            navigationItem.title = task.myName
            nameTextField.text = task.myName
            descriptionTextView.text = task.myDescription
        }
        
        // Enable the Save button only if the text field has a valid Task name
        updateSaveButtonState()
        
        /*// Notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        descriptionTextView.resignFirstResponder()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
    }
    
    //MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.lightGray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.white
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 200
    }
    
    /*func updateTextView(notification:Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardEndFrameScreenCordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            descriptionTextView.contentInset = UIEdgeInsets.zero
        } else {
            descriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            descriptionTextView.scrollIndicatorInsets = descriptionTextView.contentInset
        }
        descriptionTextView.scrollRangeToVisible(descriptionTextView.selectedRange)
    }*/
    
    //MARK: Navigation
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways
        let isPresentingInAddTaskMode = presentingViewController is UINavigationController
        
        if isPresentingInAddTaskMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The TaskViewController is not inside a navigation controller")
        }
        
    }
    
    // This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let description = descriptionTextView.text
        
        // Set the task to be passed to TaskTableViewController after the unwind segue
        task = Task(aName: name, aDescription: description, aState: false)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }


}

