//
//  ImageStore.swift
//  Quiz
//
//  Created by 林皓文 on 2022/11/9.
//

import UIKit

class ImageStore {
    var allItems = [Item]()
    let cache = NSCache<NSString,UIImage>()
    
    let imageArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("images.plist")
    }()
    
    @objc func saveChanges() -> Bool {
        print("Saving items to: \(imageArchiveURL)")
        do{
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allItems)
            try data.write(to: imageArchiveURL, options: [.atomic])
            print("Saved all of the images")
            return true
        } catch let encodingError{
            print("Error encoding allItems: \(encodingError)")
            return false
        }
        
    }
            
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        // Create full URL for image
        let url = imageURL(forKey: key)
        // Turn image into JPEG data
        if let data = image.jpegData(compressionQuality: 0.5) {
            // Write it to full URL
            try? data.write(to: url)
        }
        //self.image_reset()
    }
        
    func image(forKey key: String) -> UIImage? {
        //return cache.object(forKey: key as NSString)
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path)
        else {
            return nil
        }
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
        
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    func imageURL(forKey key: String) -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent(key)
    }
    
    /*func image_reset(){
        Fill_In_reset = true
        MCQ_reset = true
        Scores.score.mcq = [0, 0]
        Scores.score.fill = [0, 0]
    }*/
}

