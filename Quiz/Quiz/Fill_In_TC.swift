//
//  Fill_In_TC.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/5.
//

import UIKit

class Fill_In_TC: UITableViewController{
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    var list_questions = [String]()
    var list_answers = [String]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "showItem":
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get the item associated with this row and pass it along
                let item = itemStore.allItems[row]
                let detailViewController
                        = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
                detailViewController.itemStore = itemStore
            }
        case "addItem":
            let detailViewController = segue.destination as! DetailViewController
            let newItem = Item(question: "", answer: "")
            //itemStore.allItems.append(newItem)
            detailViewController.item = newItem
            detailViewController.imageStore = imageStore
            detailViewController.itemStore = itemStore
            detailViewController.isAddSegue = true
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        //tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = 65
        tableView.rowHeight = 65
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        for item in itemStore.allItems{
            if (item.isEdited){
                itemStore.anyEdited = true
                item.isEdited = false
            }
        }
        
        if (itemStore.anyEdited) == true{
            itemStore.reset()
            itemStore.anyEdited = false
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                     for: indexPath) as! ItemCell
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the table view
        let item = itemStore.allItems[indexPath.row]
        cell.question.text = item.question
        cell.answer.text = item.answer
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let item = itemStore.allItems[indexPath.row]
            // Remove the item from the store
            itemStore.removeItem(item)
            // Remove the item's image from the image store
            imageStore.deleteImage(forKey: item.itemKey)
            // Also remove that row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
    // Update the model
    to destinationIndexPath: IndexPath) {
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}
