//
//  CompanyInfoViewController.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

class CompanyInfoViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var companyLogo: PosterImageView!
    @IBOutlet weak var followMeOutlet: CustomButton!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var favoriteButtonOutlet: UIButton!
    @IBOutlet weak var aboutCompany: UITextView!
    @IBOutlet weak var visitButtonOutlet: CustomButton!
    @IBOutlet weak var memberButtonOutlet: UIButton!
    
    //MARK:- Variables
    private var isFollowed: Bool = false
    private var isFavorite: Bool = false
    var members: [String] = []
    var companyInfo: CompanyInfo?
    weak var companyInfoDelegate: CompanyInfoUpdateDelegate?
    
    //MARK:- View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isFollowed = DataManager.shared.isFollowing(companyId: (companyInfo?.id)!)
        isFavorite = DataManager.shared.isCompanyFavorite(companyId: (companyInfo?.id!)!)
        setupFollowMeButton()
        setupVisitWebsiteButton()
        companyName.text = companyInfo?.company ?? ""
        aboutCompany.text = companyInfo?.about ?? ""
        memberButtonOutlet.setTitle("View all \(companyInfo?.members?.count ?? 0) members of the \(companyInfo?.company ?? "")", for: .normal)
        aboutCompany.isEditable = false
        aboutCompany.isSelectable = false
        companyLogo.loadImagesUsingLocalCache(imageURL: companyInfo?.logo)
        setupFavoriteButton()
    }
    
    func setupFollowMeButton() {
        if isFollowed {
            followMeOutlet.setTitle("Following", for: .normal)
            followMeOutlet.setTitleColor(.white, for: .normal)
            followMeOutlet.setTitle("Following", for: .highlighted)
            followMeOutlet.backgroundColor = .systemBlue
        } else {
            followMeOutlet.setTitle("Follow", for: .normal)
            followMeOutlet.setTitle("Follow", for: .highlighted)
            followMeOutlet.setTitleColor(.systemBlue, for: .normal)
            followMeOutlet.backgroundColor = .clear
        }
    }
    
    func setupVisitWebsiteButton() {
        visitButtonOutlet.setTitle("Visit Website", for: .normal)
        visitButtonOutlet.setTitle("Visit Website", for: .highlighted)
        visitButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        visitButtonOutlet.backgroundColor = .clear
    }
    
    @IBAction func followMeAction(_ sender: Any) {
        isFollowed = !isFollowed
        setupFollowMeButton()
        companyInfoDelegate?.didUpdateCompanyFollow(isFollow: isFollowed, companyId: (companyInfo?.id)!)
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        isFavorite = !isFavorite
        setupFavoriteButton()
        companyInfoDelegate?.didUpdateCompanyFavorite(isFavorite: isFavorite, companyId: (companyInfo?.id)!)
    }
    
    func setupFavoriteButton() {
        if isFavorite {
            favoriteButtonOutlet.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButtonOutlet.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    @IBAction func visitWebsiteAction(_ sender: Any) {
        if let websiteURL = companyInfo?.website {
            if let url = URL(string: websiteURL) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func membersAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let membersVC: MembersViewController = storyBoard.instantiateViewController(identifier: "membersVC")
        membersVC.members = companyInfo?.members ?? []
        membersVC.companyName = companyInfo?.company ?? ""
        membersVC.partOfOneCompany = true
        self.navigationController?.pushViewController(membersVC, animated: true)
    }

}
