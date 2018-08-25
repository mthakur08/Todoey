//
//  ViewController.swift
//  Todoey
//
//  Created by Manish Thakur on 8/12/18.
//  Copyright © 2018 Manish Thakur. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class TodoListViewController: SwipeTableViewController{
    
    // searchBar IB action
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems : Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
         loadItems()
        }
    }
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        

        
    }

    //MARK: - Tableview DataSource Methods
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        guard let colorHex = selectedCategory?.cellColor else{ fatalError()}
            
        title = selectedCategory?.name
        
        searchBar.barTintColor = UIColor(hexString: colorHex)
        
        updateColor(colorHex)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateColor("1D9BF6")
        
    }
    
    //MARK
    
    func updateColor(_ colorHexCode : String)
    {
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation controller does not exist")
        }
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
        cell.textLabel?.text = item.title
            
            
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(todoItems!.count)))
                {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }

        
        cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let item = todoItems?[indexPath.row] {
            do{
            try realm.write{
            item.done = !item.done
            //    realm.delete(item)
                }}
            catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        

        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    //MARK: - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField : UITextField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
         

            
            if let currentCategory = self.selectedCategory{
            
            do{
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error writing to realm \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    

    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()

        }
    
    override func updateModel(at indexPath: IndexPath){
        
        if let itemPresent = todoItems?[indexPath.row]
        {
            
            do {
                try self.realm.write{
                    self.realm.delete(itemPresent)
                    
                    //self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }
                
            } catch {
                print("Error indeleting item \(error)")
            }
            //  tableView.reloadData()
        }
        
    }
    
    }

//MARK: - UISearchBar methods


extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                  searchBar.resignFirstResponder()
            }

        }
    }

}




