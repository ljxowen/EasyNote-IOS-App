//
//  AddDiaryViewController.swift
//  shan2150_finalproject
//
//  Created by 。。。。。。。 on 2021/4/6.
//

import UIKit
import CoreData

class AddDiaryViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var diaryTitleTextField: UITextField!
    @IBOutlet weak var diaryContentTextView: UITextView!
    @IBOutlet weak var diaryTypeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var sleecedImageB: UIButton!
    public var showDiary: Diarys?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var remindSwitch: UISwitch!
    @IBOutlet weak var backimageView: UIImageView!
    
    @IBOutlet weak var largeB: UIButton!
    fileprivate var isEdit: Bool = false
    
    /// Detail Image View To show image
    lazy var detailImageView: UIImageView = {
        let object = UIImageView()
        object.backgroundColor = UIColor.black
        object.contentMode = .scaleAspectFit
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(tapGesture)
        return object
    }()
    
    /// Tap detail ImageView to dismiss
    lazy var tapGesture: UITapGestureRecognizer = {
        let object = UITapGestureRecognizer(target: self, action: #selector(detailImageTapAction))
        return object
    }()
    
    /// diary category
    fileprivate var categiries: [String] = ["Note", "Remind", "Calender", "Birthday", "Drawing"]
    
    lazy var imagePicker: UIImagePickerController = {
        let objcet = UIImagePickerController()
        objcet.delegate = self
        objcet.sourceType = .photoLibrary
        return objcet
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backimageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "bacgroundImage3", ofType: "jpg") ?? "")
        diaryContentTextView.layer.borderWidth = 1 / UIScreen.main.scale
        diaryContentTextView.layer.borderColor = UIColor.lightGray.cgColor
        diaryContentTextView.layer.cornerRadius = 4

        if let value = showDiary {
            /// Show Diary Only, can't edit
            isEdit = true
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationItem.title = value.title
            diaryContentTextView.text = value.content
            diaryTitleTextField.text = value.title
            diaryTypeTextField.text = value.category
            
            if let date = value.remindTime {
                datePicker.date = date
            }
            remindSwitch.isOn = !value.isReminded
            
            /// Load Image From Sandbox
            if let imageKey = value.image, let data = UserDefaults.standard.data(forKey: imageKey), let image = UIImage(data: data) {
                imageView.image = image
                imageView.backgroundColor = nil
            }
        } else {
            datePicker.minimumDate = Date()
        }
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {

        
        
        guard let diaryTitle = diaryTitleTextField.text?.trimmingCharacters(in: .whitespaces), diaryTitle.count > 0 else {
            let controller = UIAlertController(title: "Please enter diary title", message:"", preferredStyle: UIAlertController.Style.alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
            }))
            present(controller, animated: true, completion: nil)
            return
        }
        
        guard let content = diaryContentTextView.text?.trimmingCharacters(in: .whitespaces), content.count > 0 else {
            let controller = UIAlertController(title: "Please enter diary content", message:"", preferredStyle: UIAlertController.Style.alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
            }))
            present(controller, animated: true, completion: nil)
            return
        }
        
        guard let category = diaryTypeTextField.text?.trimmingCharacters(in: .whitespaces), category.count > 0 else {
            let controller = UIAlertController(title: "Please select diary category", message:"", preferredStyle: UIAlertController.Style.alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
            }))
            present(controller, animated: true, completion: nil)
            return
        }
        
        if let value = showDiary {
            value.title = diaryTitle
            value.content = content
            value.category = category
            
            value.remindTime = datePicker.date
            value.isReminded = !remindSwitch.isOn
            
            /// Save Image To Sandbox
            if let image = imageView.image, let data = image.pngData() {
                let imageKey = "\(UUID().uuidString).png"
                UserDefaults.standard.setValue(data, forKey: imageKey)
                value.image = imageKey
            }
            AppDelegate.sharedDelegate.saveContext()
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
                
                let content = UNMutableNotificationContent()
                content.title = "Remind"
    //                    content.subtitle = ""
                content.body = "It's time to do \(value.title ?? "")"
                content.badge = 1
                
                let dateComponents =  Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: value.remindTime!)
    //                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: self.isEveryDay)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { err in
                    err != nil ? print("Fail to add local notification", err!.localizedDescription) : print("Succesful add local notification")
                }
            }
            
        } else {
            /// Create Core Data Entry
            let diary = Diarys(context: AppDelegate.viewContext)
            diary.title = diaryTitle
            diary.content = content
            diary.category = category
            diary.date = Date()
            
            diary.remindTime = datePicker.date
            diary.isReminded = !remindSwitch.isOn
            
            /// Save Image To Sandbox
            if let image = imageView.image, let data = image.pngData() {
                let imageKey = "\(UUID().uuidString).png"
                UserDefaults.standard.setValue(data, forKey: imageKey)
                diary.image = imageKey
            }
            AppDelegate.sharedDelegate.saveContext()
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
                let content = UNMutableNotificationContent()
                content.title = "Remind"
                    
                content.body = "It's time to do \(diary.title ?? "")"
                content.badge = 1
                
                let dateComponents =  Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: diary.remindTime!)
    //                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: self.isEveryDay)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { err in
                    err != nil ? print("Fail to add local notification", err!.localizedDescription) : print("Succesful add local notification")
                }
            }
        }
        

        
        
        
        
        
        
        let controller = UIAlertController(title: "\(isEdit ? "Edit" : "Add") Diary Successfully", message:"", preferredStyle: UIAlertController.Style.alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectImageAction(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func dateDidChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    
    /// Show large image
    /// - Parameter sender: sender description
    @IBAction func seeDetailImage(_ sender: UIButton) {
        guard let image = imageView.image else {
            
            let controller = UIAlertController(title: "Please select diary image", message:"", preferredStyle: UIAlertController.Style.alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
            }))
            present(controller, animated: true, completion: nil)
            
            return
        }
        view.endEditing(true)
        
        if self.detailImageView.superview == nil {
            /// Add to KeyWindow
            UIApplication.shared.windows[0].addSubview(self.detailImageView)
        }
        
        UIApplication.shared.windows[0].bringSubviewToFront(self.detailImageView)
        self.detailImageView.isHidden = false
        self.detailImageView.image = image
        self.detailImageView.frame = self.imageView.frame;
        
        /// Animation to Show Detail Image View
        UIView.animate(withDuration: 0.25) {
            self.detailImageView.frame = UIScreen.main.bounds
        }
        
    }
    
    /// hidden detail Image
    @objc func detailImageTapAction() {
        UIView.animate(withDuration: 0.25) {
            self.detailImageView.frame = self.imageView.frame
        } completion: { (flag) in
            self.detailImageView.isHidden = true
        }

    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == diaryTypeTextField {
            /// Category can't be edit, only show sheet
            showDiaryTypeSheet()
            return false
        }
        return true
    }
    
    fileprivate func showDiaryTypeSheet() {
        let controller = UIAlertController(title: "Please select diary category", message:"", preferredStyle: UIAlertController.Style.actionSheet)
        
        for category in categiries {
            controller.addAction(UIAlertAction(title: category, style: .default, handler: { (_) in
                self.diaryTypeTextField.text = category
            }))
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        present(controller, animated: true, completion: nil)
        
    }
        
    /// imagePicker to selected photo from PhotoLibrary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageView.backgroundColor = nil
            self.imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
