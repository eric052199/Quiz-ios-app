//
//  score VC.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/3.
//

import UIKit

class score_VC: UIViewController{
    
    @IBOutlet weak var label_c: UILabel!
    @IBOutlet weak var label_i: UILabel!
    @IBOutlet weak var count_c: UILabel!
    @IBOutlet weak var count_i: UILabel!
    
    var correct: Int = 0
    var incorrect: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if isEdit.Fill_In_isEdit.fill_edit {
            view.backgroundColor = UIColor.white
            Scores.score.mcq[0] = 0
            Scores.score.mcq[1] = 0
            Scores.score.fill[0] = 0
            Scores.score.fill[1] = 0
            count_c.text = "0"
            count_i.text = "0"
        }
        
        else{
            correct = Scores.score.mcq[0] + Scores.score.fill[0]
            incorrect = Scores.score.mcq[1] + Scores.score.fill[1]
            
            count_c.text = String(correct)
            count_i.text = String(incorrect)
            
            if(correct > incorrect){
                view.backgroundColor = UIColor.systemGreen
            }
            else if(correct < incorrect){
                view.backgroundColor = UIColor.systemRed
            }
            else{
                view.backgroundColor = UIColor.white
            }
        }
        
        isEdit.Fill_In_isEdit.fill_edit = false
    }
}
