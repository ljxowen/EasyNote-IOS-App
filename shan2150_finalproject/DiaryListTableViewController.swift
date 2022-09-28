//
//  DiaryListTableViewController.swift
//  shan2150_finalproject
//
//  Created by 。。。。。。。 on 2021/4/6.
//

import UIKit
import CoreData

class DiaryListTableViewController: UITableViewController {
    

    /// All Diary Data
    fileprivate var dataSource: [Diarys] = []

    /// Search result Diary Data
    fileprivate var filterDataSource: [Diarys] = []
    
    /// Search Controller
    lazy var diarySearchController: UISearchController = {
        let object = UISearchController(searchResultsController: nil)
        object.searchBar.searchTextField.placeholder = "Search diary"
        object.searchResultsUpdater = self
        object.delegate = self
        object.searchBar.delegate = self
        object.obscuresBackgroundDuringPresentation = false
        return object
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "bacgroundImage3", ofType: "jpg") ?? "") {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        tableView.register(UINib(nibName: "DiaryListTableViewCell", bundle: nil), forCellReuseIdentifier: "DiaryListTableViewCell")
        navigationItem.searchController = diarySearchController
        tableView.tableFooterView = UIView()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
            if !status {
                print("OFF")
                DispatchQueue.main.async {
                let alert = UIAlertController(title: "The app needs you to give notice permission. Click OK to open the settings.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, completionHandler: nil)
                    }
                }))
                alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                    return
                }
                
                
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllDiary()
        showRemindAlertIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
    }
    
    /// Load All Diary Data
    fileprivate func loadAllDiary() {
        let fetchRequest = NSFetchRequest<Diarys>(entityName: "\(Diarys.self)")
        /// Sort by date
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let result = try AppDelegate.viewContext.fetch(fetchRequest)
            dataSource = result
            tableView.reloadData()
        } catch {
            debugPrint("Could not fetch entites of type \(Diarys.self): \(error.localizedDescription)")
        }
    }
    
    /// Show Remind Alert
    func showRemindAlertIfNeed() {
 
        var hasRemindDiary = false
        var remindDiary: Diarys! = nil
        for item in self.dataSource {
            if let remindDate = item.remindTime {
             
                if !item.isReminded && remindDate.timeIntervalSinceNow <= 0 {
                    hasRemindDiary = true
                    remindDiary = item
                }
  
            }
        }
        
        if !hasRemindDiary {
            return
        }

        
        
        remindDiary.isReminded = true
        AppDelegate.sharedDelegate.saveContext()
        //let controller = UIAlertController(title: "Remind", message: "It's time to do \(remindDiary!.title ?? "")", preferredStyle: UIAlertController.Style.alert)
        //controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            //self.showRemindAlertIfNeed()
       // }))
       // present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diarySearchController.isActive ? filterDataSource.count : dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryListTableViewCell", for: indexPath) as! DiaryListTableViewCell
        if diarySearchController.isActive {
            cell.diarys = filterDataSource[indexPath.row]
        } else {
            cell.diarys = dataSource[indexPath.row]
        }
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        /// Delete Action
        if editingStyle == .delete {
            if diarySearchController.isActive {
                /// in Search
                let diary = filterDataSource.remove(at: indexPath.row)
                if let index = dataSource.firstIndex(of: diary) {
                    dataSource.remove(at: index)
                }
                AppDelegate.viewContext.delete(diary)
                AppDelegate.sharedDelegate.saveContext()
            } else {
                let diary = dataSource.remove(at: indexPath.row)
                AppDelegate.viewContext.delete(diary)
                AppDelegate.sharedDelegate.saveContext()
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if diarySearchController.isActive {
            performSegue(withIdentifier: "showDiaryController", sender: filterDataSource[indexPath.row])
        } else {
            performSegue(withIdentifier: "showDiaryController", sender: dataSource[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDiaryController" {
            /// pass Diarys to DetailController
            guard let controller = segue.destination as? AddDiaryViewController else {
                return
            }
            guard let diary = sender as? Diarys else {
                return
            }
            controller.showDiary = diary
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DiaryListTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    /// Call when search controller did change
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchKeyword = searchController.searchBar.text?.lowercased() ?? ""
        
        filterDataSource = dataSource.filter({ (value) -> Bool in
            return (value.title?.lowercased().contains(searchKeyword)) ?? false || (value.content?.lowercased().contains(searchKeyword)) ?? false || (value.category?.lowercased().contains(searchKeyword)) ?? false
        })
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterDataSource = []
        tableView.reloadData()
    }
}
