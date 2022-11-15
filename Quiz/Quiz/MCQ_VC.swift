
import UIKit

class MCQ_VC: UIViewController{
    
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    private let selections: [String] = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
    ]
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var submit: UIButton!
    @IBOutlet var nextQuestion: UIButton!
    @IBOutlet weak var your_selection: UITextField!
    
    let questions: [String] = [
        "What is 1*1?",
        "What is 2*2?",
        "What is 3*3?"
    ]
    
    let answers: [String] = [
        "1",
        "4",
        "9"
    ]
    var currentQuestionIndex: Int = 0
    
    @IBAction func showNextQuestion(_ sender: UIButton){
        currentQuestionIndex += 1
        let question: String = questions[currentQuestionIndex]
        questionLabel.text = question
        nextQuestion.isEnabled = false
        submit.isEnabled = true
        resultLabel.text = ""
        
    }
    
    @IBAction func submitClicked(_ sender: UIButton){
        let answer: String = answers[currentQuestionIndex]
        
        if answer == your_selection.text{
            Scores.score.mcq[0] += 1
            resultLabel.text = "Correct"
            resultLabel.textColor = UIColor.green
        }
        else{
            Scores.score.mcq[1] += 1
            resultLabel.text = "Incorrect"
            resultLabel.textColor = UIColor.red
        }
        your_selection.text = ""
        nextQuestion.isEnabled = true
        submit.isEnabled = false
        
        if currentQuestionIndex == questions.count-1{
            nextQuestion.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = questions[currentQuestionIndex]
        pickerView.dataSource = self
        pickerView.delegate = self
        your_selection.inputView = pickerView
        nextQuestion.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (itemStore.MCQ_reset){
            currentQuestionIndex = 0
            questionLabel.text = questions[currentQuestionIndex]
            nextQuestion.isEnabled = false
            submit.isEnabled = true
            //answerField.isEnabled = true
            your_selection.text = ""
            resultLabel.text = ""
            itemStore.MCQ_reset = false
        }
        
        else{
            questionLabel.text = questions[currentQuestionIndex]
        }
    }
}

extension MCQ_VC: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        your_selection.text = selections[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selections[row]
    }
}
