//
//  DrawViewController.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/11.
//

import Foundation
import UIKit

class DrawViewController: UIViewController{
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let drawView = self.view as! DrawView
        let QA = drawView.item!
        let nImage = drawView.asImage()
        
        if (drawView.finishedLines.count != 0){
            if (QA.drawLines.count == drawView.finishedLines.count){
                for i in 0..<QA.drawLines.count{
                    if QA.drawLines[i].begin != drawView.finishedLines[i].begin
                        || QA.drawLines[i].end != drawView.finishedLines[i].end
                        || QA.drawLines[i].color != drawView.finishedLines[i].color{
                        drawView.saveImage(image: nImage)
                        drawView.saveLines()
                        break
                    }
                }
            }
            else{
                drawView.saveImage(image: nImage)
                drawView.saveLines()
            }
        }
        else{
            if QA.drawLines.count != 0{
                drawView.imageStore.deleteImage(forKey: QA.itemKey)
                QA.isEdited = true
            }
        }
        
        print("left draw view controller")
    }

}
