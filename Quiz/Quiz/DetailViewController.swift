//
//  DetailViewController.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/6.
//

import UIKit
class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    var isAddSegue = false
    
    var item: Item!{
        didSet {
            navigationItem.title = item.question
        }
    }
    
    @IBOutlet var questionField: UITextField!
    @IBOutlet var answerField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var remove: UIButton!
    @IBAction func removeImage(_ sender: UIButton) {
        if imageView.image != nil {
            imageView.image = nil
            imageStore.deleteImage(forKey: item.itemKey)
            item.isEdited = true
            item.drawLines = []
        }
    }

    @IBAction func choosePhotoSource(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.barButtonItem = sender
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                //print("Present camera")
                let imagePicker = self.imagePicker(for: .camera)
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction
                = UIAlertAction(title: "Photo Library", style: .default) { _ in
            //print("Present photo library")
            let imagePicker = self.imagePicker(for: .photoLibrary)
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.barButtonItem = sender
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageToDisplay = imageStore.image(forKey: item.itemKey)
        imageView.image = imageToDisplay
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        questionField.text = item.question
        answerField.text = item.answer
        dateLabel.text = dateFormatter.string(from: item.dateCreated)
        
        // Get the item key
        let key = item.itemKey
        // If there is an associated image with the item, display it on the image view
        let imageToDisplay = imageStore.image(forKey: key)
        imageView.image = imageToDisplay
    }
    
    func imagePicker(for sourceType: UIImagePickerController.SourceType)
    -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        return imagePicker
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clear first responder
        view.endEditing(true)
        
        // "Save" changes to item
        if (item.question != questionField.text || item.answer != answerField.text){
            item.question = questionField.text ?? ""
            item.answer = answerField.text ?? ""
            item.isEdited = true
            
            //from something to empty
            if (item.question == "" || item.answer == ""){
                itemStore.removeItem(item)
                isAddSegue = false
            }
            
            // means it's a new QA
            if isAddSegue{
                itemStore.allItems.append(item)
                isAddSegue = false
            }
        }
        print("is item edited: \(item.isEdited)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Get picked image from info dictionary
        let image = info[.originalImage] as! UIImage
        
        // Store the image in the ImageStore for the item's key
        imageStore.setImage(image, forKey: item.itemKey)
        
        if(imageView.image != image){
            // Put that image on the screen in the image view
            imageView.image = image
            self.item.isEdited = true
        }
        item.drawLines = []
        
        // Take image picker off the screen - you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if (textField == answerField){
            let allowedCharacters = CharacterSet.decimalDigits.union (CharacterSet (charactersIn: ".")).union (CharacterSet (charactersIn: "-"))
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "drawItem":
            let drawView = segue.destination.view as! DrawView
            drawView.item = item
            drawView.imageStore = imageStore
            print("lines\( item.drawLines.count)")
            if item.drawLines.count > 0 {
                drawView.finishedLines = item.drawLines
            }
            else{
                drawView.finishedLines = [Line]()
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
