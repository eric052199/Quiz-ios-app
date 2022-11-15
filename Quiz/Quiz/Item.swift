//
//  Item.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/5.
//

import UIKit

class Item: Equatable, Codable{
    var question: String
    var answer: String
    let dateCreated: Date
    let itemKey: String
    var isEdited: Bool
    var drawLines = [Line]()
    let drawEdited: Bool
    
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
        self.dateCreated = Date()
        self.isEdited = false
        self.itemKey = UUID().uuidString
        self.drawEdited = false
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.question == rhs.question
            && lhs.answer == rhs.answer
    }

    
}
