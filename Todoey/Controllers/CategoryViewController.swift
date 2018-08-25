//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Manish Thakur on 8/20/18.
//  Copyright © 2018 Manish Thakur. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

        tableView.separatorStyle = .none
        
    }

    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let currentCategory = categories?[indexPath.row]{
        
        cell.textLabel?.text = currentCategory.name
        
        //view.backgroundColor = UIColor.randomFlat
            
        guard let color = UIColor(hexString: currentCategory.cellColor) else {fatalError()}
        
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            
        }
        
        
        return cell
        
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
    }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItem", sender: self)

        }
        
    
        
    
  
    
    //MARK: - Add New Categories
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField : UITextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category Item", message: "", preferredStyle: .alert)

        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellColor = UIColor.randomFlat.hexValue()
            
            
            
            self.save(category: newCategory)
            
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    
    func save(category : Category){
        
        do{
            try realm.write {
                realm.add(category)
            }
        } catch
        {
            print("Error saving : \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath)
    {
                    if let categoryPresent = categories?[indexPath.row]
                    {
        
                        do {
                            try realm.write{
                                realm.delete(categoryPresent)
                                
                                //self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                
                            }
                            
                        } catch {
                            print("Error indeleting item \(error)")
                        }
                      //  tableView.reloadData()
                    }
    }
}


