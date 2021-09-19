//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Konstantin on 17.09.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let mainView = UIView()
    private let cellId = "cell"
    private var tasks: [Task] = []
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let colorBlue = UIColor(
        displayP3Red: 21/255,
        green: 101/255,
        blue: 192/255,
        alpha: 194/255
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func setupView() {
        view.backgroundColor = .white
//        addViewInSafeArea()
        setupNavigationBar()
    }
    
    private func addTableView() {
        
    }
    
    private func setupNavigationBar() {
        
        title = "Tasks list"
        
        navigationController?.navigationBar.barTintColor = colorBlue
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//        view.backgroundColor = .blue
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = colorBlue
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add", style: .plain, target: self, action: #selector(addNewTask)
        )
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAllTask))
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Taks", message: "What do you want to do?")
    }
    
    @objc private func deleteAllTask() {
        
        for task in tasks {
            managedContext.delete(task)
            tasks = []
        }
        
        do {
            try managedContext.save()
            
        } catch let error {
            print(error)
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Setup Table View Cell

extension ViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        
        return cell
    }

}

// MARK: - Editing and Delete method in Table View

extension ViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let task = tasks[indexPath.row]
        showAlert(title: "Edit task", message: "Enter new value", currentTask: task) { (newValue) in
            
            cell.textLabel?.text = newValue
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        if editingStyle == .delete {
            deleteTask(task, indexPath: indexPath)
        }
    }
}

// MARK: - Work with Data Base

extension ViewController {
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
    }
    
    private func saveTask(_ taskName: String) {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! Task
        
        task.name = taskName
        
        do {
            try managedContext.save()
            tasks.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic
            )
        } catch let error {
            print(error)
        }
    }
    
    private func editTask(_ task: Task, newName: String) {
        do {
            task.name = newName
            try managedContext.save()
        } catch let error {
            print("Failed to save task", error)
        }
    }
    
    private func deleteTask(_ task: Task, indexPath: IndexPath) {
        
        managedContext.delete(task)
        
        do {
            try managedContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
}

// MARK: - Setup Alert Controller

extension ViewController {
    
    private func showAlert(title: String,
                           message: String,
                           currentTask: Task? = nil,
                           completion: ((String) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let newValue = alert.textFields?.first?.text, !newValue.isEmpty else { return }
            
            currentTask != nil ? self.editTask(currentTask!, newName: newValue) : self.saveTask(newValue)
            if completion != nil { completion!(newValue) }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            
            
            
        }
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        if currentTask != nil {
            alert.textFields?.first?.text = currentTask?.name
        }
        
        present(alert, animated: true)
    }
    
}

