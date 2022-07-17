//
//  ViewController.swift
//  TodoGo
//
//  Created by Асхат Баймуканов on 25.03.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let colorHex = selectedCategory?.color {

            title = selectedCategory!.name

//            guard let navBar = navigationController?.navigationBar else {fatalError("NavigationController doesnt exist.")}

            if let navBarColor = UIColor(hexString: colorHex) {
                
                let navBarAppearance = UINavigationBarAppearance()
                let navBar = navigationController?.navigationBar
                let navItem = navigationController?.navigationItem
                navBarAppearance.configureWithOpaqueBackground()
                
                let contrastColour = ContrastColorOf(navBarColor, returnFlat: true)
                navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColour]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColour]
                navBarAppearance.backgroundColor = navBarColor
                navItem?.rightBarButtonItem?.tintColor = contrastColour
                navBar?.tintColor = contrastColour
                navBar?.standardAppearance = navBarAppearance
                navBar?.scrollEdgeAppearance = navBarAppearance
                
                self.navigationController?.navigationBar.setNeedsLayout()

//                navBar.backgroundColor = navBarColor
//                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
//                navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
//                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = FlatWhite()
            }

        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       // let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel!.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
            // Ternary operator ==>
            // Value = condition ? valueIfTrue : valueIfFalse
            
            //cell.accessoryType = item.done == true ? .checkmark : .none
            cell.accessoryType = item.done ? .checkmark : .none
            
            // Set the cell's accessoryType depending on whether the item.done is true
            // If it is true, then set it to .checkmark
            // If it's not true, then set it to .none
            
            // Next code we replaced with ternary operator
    //        if item.done == true {
    //            cell.accessoryType = .checkmark
    //        } else {
    //            cell.accessoryType = .none
    //        }
        } else {
            cell.textLabel?.text = "No Items added"
        }

        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        //This is right order on deleting data from context and tableView
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//        saveItems()
        //the above code is replacing the below one.
        
//        if itemArray[indexPath.row].done == false {
//            itemArray[indexPath.row].done = true
//        } else {
//            itemArray[indexPath.row].done = false
//        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed (_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New TodoGo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What wiil happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new Item, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

    //MARK: - Model Manipulation Methods
    
    //    func saveItems() {
    //
    //        do {
    //           try context.save()
    //        } catch {
    //            print("Error saving context \(error)")
    //        }
    //
    //        self.tableView.reloadData()
    //    }
    
    func loadItems () {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
////        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
////
////        request.predicate = compoundPredicate
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item,\(error)")
            }
        }
    }
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
 //       let request : NSFetchRequest<Item> = Item.fetchRequest()
        
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
 //       request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
 //       loadItems(with: request, predicate: predicate)
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

