//
//  DrawView.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/9.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate{
    var item: Item!
    var imageStore: ImageStore!
    var currentLines = [NSValue:Line]()
    var finishedLines: [Line]!
    var selectedLineIndex: Int? {
        didSet{
            if selectedLineIndex == nil{
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var moveRecognizer: UIPanGestureRecognizer!
    var longPressRecognizer: UILongPressGestureRecognizer!
    
    /*@IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }*/
    
    @IBInspectable var currentLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        for line in finishedLines{
            line.color.setStroke()
            stroke(line)
        }
        
        for (_, line) in currentLines {
            line.color.setStroke()
            stroke(line)
        }
        
        if let index = selectedLineIndex{
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events print (#function)
        for touch in touches {
            let location = touch.location(in: self)
            let newLine = Line(begin: location, end: location, color: currentLineColor)
            let key = NSValue (nonretainedObject: touch)
            currentLines [key] = newLine
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print (#function)
        
        for touch in touches{
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        
        for touch in touches {
            let key = NSValue (nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location (in: self)
                line.color = currentLineColor
                finishedLines.append(line)
                currentLines.removeValue (forKey: key)
            }
        }

        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Log statement to see the order of events
        print(#function)
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    required init ? (coder aDecoder: NSCoder) {
        super.init (coder: aDecoder)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail : doubleTapRecognizer)
        addGestureRecognizer (tapRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self,action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
        
    }
    
    // simultaneous recognizer, only pan gesture recognizer has delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        print ("Recognized a double tap")
        
        let alertController = UIAlertController(title: "Confirm Delete",
                                                message: "Delete all lines?",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            print("Cancel deleting")
            return
        }
        
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.selectedLineIndex = nil
            self.currentLines.removeAll()
            self.finishedLines.removeAll()
            self.setNeedsDisplay()
            print("Confirm deletion")
        }
        
        alertController.addAction(confirmAction)

        parentViewController?.present(alertController, animated: true, completion: nil)
        /*selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()*/
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        // Grab the menu controller
        let menu = UIMenuController.shared
        if selectedLineIndex != nil {
        // Make DrawView the target of menu item action messages
            becomeFirstResponder()
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete",action: #selector(DrawView.deleteLine(_:)))
            let toBlack = UIMenuItem(title: "toBlack",action: #selector(DrawView.toBlack(_:)))
            let toBlue = UIMenuItem(title: "toBlue",action: #selector(DrawView.toBlue(_:)))
            let toRed = UIMenuItem(title: "toRed",action:
                #selector(DrawView.toRed(_:)))
            let toYellow = UIMenuItem(title: "toYellow",action: #selector(DrawView.toYellow(_:)))
            menu.menuItems = [deleteItem, toBlack, toBlue, toRed, toYellow]
            // Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        }
        else {
        // Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        setNeedsDisplay()
    }
    
    @objc func deleteLine(_ sender: UIMenuController) {
        // Remove the selected line from the list of finishedLines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            // Redraw everything
            setNeedsDisplay()
        }
    }
    
    // change to black
    @objc func toBlack(_ sender: UIMenuController){
        if let index = selectedLineIndex {
            finishedLines[index].color = UIColor.black
            selectedLineIndex = nil
            setNeedsDisplay()
        }
    }
    // set to black
    @objc func Black(_ sender: UIMenuController){
        currentLineColor = UIColor.black
    }
    
    // change to blue
    @objc func toBlue(_ sender: UIMenuController){
        if let index = selectedLineIndex {
            finishedLines[index].color = UIColor.systemBlue
            selectedLineIndex = nil
            setNeedsDisplay()
        }
    }
    // set to blue
    @objc func Blue(_ sender: UIMenuController){
        currentLineColor = UIColor.systemBlue
    }
    
    // change to red
    @objc func toRed(_ sender: UIMenuController){
        if let index = selectedLineIndex {
            finishedLines[index].color = UIColor.systemRed
            selectedLineIndex = nil
            setNeedsDisplay()
        }
    }
    // set to red
    @objc func Red(_ sender: UIMenuController){
        currentLineColor = UIColor.systemRed
    }
    
    // change to yellow
    @objc func toYellow(_ sender: UIMenuController){
        if let index = selectedLineIndex {
            finishedLines[index].color = UIColor.systemYellow
            selectedLineIndex = nil
            setNeedsDisplay()
        }
    }
    // set to yellow
    @objc func Yellow(_ sender: UIMenuController){
        currentLineColor = UIColor.systemYellow
    }
    
    func indexOfLine(at point: CGPoint) -> Int? {
        // Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0{
                    return index
                }
            }
        }
        
        // If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    // long press
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        print("Recognized a long press")
        if gestureRecognizer.state == .began {
            //let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll()
            }
            else{
                // blank space
                print("blank space")
                let menu = UIMenuController.shared
                let Black = UIMenuItem(title: "Black",action: #selector(DrawView.Black(_:)))
                let Blue = UIMenuItem(title: "Blue",action: #selector(DrawView.Blue(_:)))
                let Red = UIMenuItem(title: "Red",action: #selector(DrawView.Red(_:)))
                let Yellow = UIMenuItem(title: "Yellow",action: #selector(DrawView.Yellow(_:)))
                menu.menuItems =  [Black, Blue, Red, Yellow]
                let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
                menu.setTargetRect(targetRect, in: self)
                menu.setMenuVisible(true, animated: true)
                
            }
        }
        setNeedsDisplay()
    }
    
    // move line
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard longPressRecognizer.state == .changed else {
            return
        }
        // If a line is selected...
        if let index = selectedLineIndex {
        // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                // Make sure there are no copy and paste typos!
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                // Redraw the screen
                setNeedsDisplay()
            }
        }
        else {
            return
        }
    }
    
    
}

extension DrawView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    public func saveImage(image: UIImage) {
//        let image = self.asImage()
        imageStore.setImage(image, forKey: item.itemKey)
        print("Draw View Image Saved \(image)")
        item.isEdited = true
    }
    
    public func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        }
    
    public func saveLines(){
        item.drawLines = finishedLines
        print("line saved \(item.drawLines)")
    }
    
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
