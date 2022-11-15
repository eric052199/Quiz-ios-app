//
//  ViewController.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/2.
//

import UIKit

class Fill_In_VC: UIViewController {
    
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var nextQuestion: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        answerField.delegate = self
        answerField.becomeFirstResponder()
        //questionLabel.text = itemStore.questions[itemStore.cur_idx]
        nextQuestion.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits.union (CharacterSet (charactersIn: ".")).union (CharacterSet (charactersIn: "-"))
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if itemStore.Fill_In_reset {
            nextQuestion.isEnabled = false
            submit.isEnabled = false
            answerField.text = ""
            resultLabel.text = ""
            itemStore.Fill_In_reset = false
        }
        
        if itemStore.questions.count == 0{
            questionLabel.text = "You have no questions."
            answerField.isEnabled = false
            submit.isEnabled = false
            nextQuestion.isEnabled = false
            resultLabel.text = ""
        }
        
        else{
            questionLabel.text = itemStore.questions[itemStore.cur_idx]
            answerField.isEnabled = true
            // load image, Get the item key
            let key = itemStore.allItems[itemStore.cur_idx].itemKey
            // If there is an associated image with the item, display it on the image view
            let imageToDisplay = imageStore.image(forKey: key)
            imageView.image = imageToDisplay
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.image = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        answerField.resignFirstResponder()
    }
    
    var answer: String?
    
    @IBAction func edittingAnswer(_ sender: UITextField) {
        if let input =  answerField.text{
            answer = input
            submit.isEnabled = true
            
            if (answerField.text == "") {
                submit.isEnabled = false
           }
        }
        else{
            answer = nil
            submit.isEnabled = false
        }
    }
    
    @IBAction func showNextQuestion(_ sender: UIButton){
        itemStore.cur_idx += 1
        let question: String = itemStore.questions[itemStore.cur_idx]
        questionLabel.text = question
        resultLabel.text = ""
        answerField.text = ""
        nextQuestion.isEnabled = false
        submit.isEnabled = true
        let key = itemStore.allItems[itemStore.cur_idx].itemKey
        let imageToDisplay = imageStore.image(forKey: key) ?? nil
        imageView.image = imageToDisplay
    }
    
    @IBAction func submitClicked(_ sender: UIButton){
        let answer: String = itemStore.answers[itemStore.cur_idx]
        let your_answer = answerField.text
        
        if answer == your_answer{
            Scores.score.fill[0] += 1
            resultLabel.text = "Correct"
            resultLabel.textColor = UIColor.green
        }
        else{
            Scores.score.fill[1] += 1
            resultLabel.text = "Incorrect"
            resultLabel.textColor = UIColor.red
        }
        answerField.resignFirstResponder()
        answerField.text = ""
        nextQuestion.isEnabled = true
        submit.isEnabled = false
        
        if itemStore.cur_idx == itemStore.questions.count-1{
            nextQuestion.isEnabled = false
        }
    }
    
    
}

extension Fill_In_VC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        answerField.resignFirstResponder()
        return true
    }
}

