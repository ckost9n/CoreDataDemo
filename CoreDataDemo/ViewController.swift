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
//    private let mainTableView = UIView()
    private let cellId = "cell"
    private var tasks: [Task] = []
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
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

    private func setupView() {
        view.backgroundColor = .white
//        addViewInSafeArea()
        setupNavigationBar()
    }
    
    private func addTableView() {
        
    }
    
//    private func addViewInSafeArea() {
//        mainView.backgroundColor = .green
//        mainView.alpha = 1
//        self.view.addSubview(mainView)
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//
//        let guide = self.view.safeAreaLayoutGuide
//        mainView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//        mainView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//        mainView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    }
    
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
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Taks", message: "What do you want to do?")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("Text field is empty")
                return
            }
            self.save(task)
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let managedContext = appDelegate.persistentContainer.viewContext
        
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
    
}

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

