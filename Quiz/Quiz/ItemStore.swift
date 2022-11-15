//
//  ItemStore.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/5.
//

import UIKit

class ItemStore{
    var allItems = [Item]()
    
    let itemArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("items.plist")
    }()
    
    var cur_idx = 0
    var MCQ_reset = false
    var Fill_In_reset = false
    var anyEdited = false
    var questions = [String]()
    var answers = [String]()
    //var userScore = [Int]()
    

    @discardableResult func createItem() -> Item{
        let newItem = Item(question: "hello", answer: "hi")
        //cur_idx += 1
        allItems.append(newItem)
        //self.reset()
        return newItem
    }
    
    @objc func saveChanges() -> Bool {
        print("Saving items to: \(itemArchiveURL)")
        do{
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allItems)
            try data.write(to: itemArchiveURL, options: [.atomic])
            print("Saved all of the items")
            return true
        } catch let encodingError{
            print("Error encoding allItems: \(encodingError)")
            return false
        }
        
    }
    
    init() {
        /*let fillin_questions: [String] = [
            "What is 4*4?",
            "What is 5*5?",
            "What is 6*6?",
            "What is 7*7?",
            "What is 8*8?",
            "What is 9*9?"
        ]
        
        let fillin_answeres: [String] = [
            "16",
            "25",
            "36",
            "49",
            "64",
            "81"
        ]
        
        for i in 0..<fillin_questions.count{
            let ques: Item = Item(question: fillin_questions[i], answer: fillin_answeres[i])
            self.allItems.append(ques)
        }
        self.reset()*/
         
        do {
            let data = try Data(contentsOf: itemArchiveURL)
            let unarchiver = PropertyListDecoder()
            let items = try unarchiver.decode([Item].self, from: data)
            self.allItems = items
        } catch {
            print("Error reading in saved items: \(error)")
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges),
                                       name: UIScene.didEnterBackgroundNotification,
                                       object: nil)
        self.reset()
    }
    
    func removeItem(_ item: Item) {
        if let index = allItems.firstIndex(of: item) {
            allItems.remove(at: index)
        }
        self.reset()
            
    }
    
    
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        // Get reference to object being moved so you can reinsert it
        let movedItem = allItems[fromIndex]
        // Remove item from array
        allItems.remove(at: fromIndex)
        // Insert item in array at new location
        allItems.insert(movedItem, at: toIndex)
        self.reset()
    }
    
    func reset(){
        questions = []
        answers = []
        for Item in allItems{
            questions.append(Item.question)
            answers.append(Item.answer)
            cur_idx = 0
        }
        Fill_In_reset = true
        MCQ_reset = true
        Scores.score.mcq = [0, 0]
        Scores.score.fill = [0, 0]
    }
    
    func add(){
        for Item in allItems{
            questions.append(Item.question)
            answers.append(Item.answer)
        }
        
    }
    
    

}


