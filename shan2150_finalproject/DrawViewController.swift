//
//  DrawViewController.swift
//  shan2150_finalproject
//
//  Created by 。。。。。。。 on 2021/4/9.
//

import UIKit
import CoreData

class DrawViewController: UIViewController {

    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var drawView: DrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        redButton.titleLabel?.adjustsFontSizeToFitWidth = true
        blueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        orangeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        purpleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        yellowButton.titleLabel?.adjustsFontSizeToFitWidth = true
        blackButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    /// Clean Draw view
    @IBAction func cleanAction(_ sender: UIButton) {
        drawView.clean()
    }
    
    /// change path color
    @IBAction func colorAction(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            /// update DrawView Color
            drawView.lineColor = color
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let image = drawView.quickImage() else {
            let controller = UIAlertController(title: "Empty hander draw", message:"", preferredStyle: UIAlertController.Style.alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
            }))
            present(controller, animated: true, completion: nil)
            
            return
        }
        
        /// Create Core Data Entry
        let diary = Diarys(context: AppDelegate.viewContext)
        let count = UserDefaults.standard.integer(forKey: "HandDrawnCount")
        UserDefaults.standard.setValue(count + 1, forKey: "HandDrawnCount")
        UserDefaults.standard.synchronize()
        diary.title = "Hand Drawn \(count + 1)"
        diary.content = "Hand Drawn"
        diary.category = "Hand Drawn"
        diary.date = Date()
        
        /// Save Image To Sandbox
        if let data = image.pngData() {
            let imageKey = "\(UUID().uuidString).png"
            UserDefaults.standard.setValue(data, forKey: imageKey)
            UserDefaults.standard.synchronize()
            diary.image = imageKey
        }
        AppDelegate.sharedDelegate.saveContext()
        
        let controller = UIAlertController(title: "Add Hand Drawn Successfully", message:"", preferredStyle: UIAlertController.Style.alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        present(controller, animated: true, completion: nil)

    }
}
