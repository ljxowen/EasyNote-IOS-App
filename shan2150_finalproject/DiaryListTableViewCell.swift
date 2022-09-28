//
//  DiaryListTableViewCell.swift
//  shan2150_finalproject
//
//  Created by 。。。。。。。 on 2021/4/9.
//

import UIKit
import CoreData

class DiaryListTableViewCell: UITableViewCell {

    @IBOutlet weak var diaryImageV: UIImageView!
    @IBOutlet weak var diaryTitleL: UILabel!
    @IBOutlet weak var diaryDateL: UILabel!
    @IBOutlet weak var diaryContentL: UILabel!
    @IBOutlet weak var diaryCategoryL: UILabel!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var grayView: UIView!
    
    public var diarys: Diarys? {
        didSet {
            diaryTitleL.text = diarys?.title
            diaryContentL.text = diarys?.content
            diaryCategoryL.text = diarys?.category
            
            /// Formatter Date
            if let date = diarys?.date {
                /// Formatter date 
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm MMM dd yyyy"
                diaryDateL.text = dateFormatter.string(from: date)
            } else {
                diaryDateL.text = nil
            }
            
            /// Load Image From Sandbox
            if let imageKey = diarys?.image, let data = UserDefaults.standard.data(forKey: imageKey), let image = UIImage(data: data) {
                diaryImageV.image = image
                diaryImageV.isHidden = false
                titleLeadingConstraint.constant = 96
            } else {
                diaryImageV.isHidden = true
                diaryImageV.image = nil
                titleLeadingConstraint.constant = 8
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /// Cornet Radius For ImageView And GrayView
        grayView.layer.cornerRadius = 6
        grayView.layer.masksToBounds = true
        
        diaryImageV.layer.cornerRadius = 6
        diaryImageV.layer.masksToBounds = true
        
        diaryContentL.numberOfLines = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
