//
//  scores.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/5.
//

import UIKit

class Scores{
    static let score = Scores()
    var mcq = [0, 0]
    var fill = [0, 0]
}

class isEdit{
    static let Fill_In_isEdit = isEdit()
    var fill_edit = false
    var fill_delete = false
    var fill_delete_index: [Int] = []
    var fill_move = false
    var fill_move_from: [Int] = []
    var fill_move_to: [Int] = []
    
}

class isAdd{
    static let Fill_IN_isAdd = isAdd()
    var fill_add = false
    var fill_add_times = 0
}
