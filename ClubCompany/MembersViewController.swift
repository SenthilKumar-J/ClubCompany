//
//  MembersViewController.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

protocol MemberSortDelegate: AnyObject {
    func didUpdateSort(sortBy: Int, sortType: Int)
}

class MembersViewController: UIViewController {
    
    @IBOutlet weak var membersTableView: UITableView!
    
    var members: [Member] = []
    var companyName: String = ""
    var partOfOneCompany: Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMemberSearch: [Member] = []
    var activityIndicator: UIActivityIndicatorView! = nil
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    var sortOrder: SortOrder = .ascending
    var sortType: SortType = .byName
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if partOfOneCompany {
            navigationItem.title = companyName + " Members"
        } else {
            navigationItem.title = "Members"
            members = DataManager.shared.getAllMembers()
            if members.count == 0 {
                DataManager.shared.membersDataDelegate = self
                setupActivityIndicator()
            }
        }
        if members.count > 0 {
            setupMembersView()
        }
    }
    
    func setupMembersView() {
        //Setting the default sort order and type
        sortMembers(sortOrder: .ascending, sortType: .byName)
        navigationController?.navigationBar.prefersLargeTitles = true
        let rightButton = UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: self, action: #selector(onSortClicked))
        navigationItem.rightBarButtonItem = rightButton
        membersTableView.delegate = self
        membersTableView.dataSource = self
        setupSearchBar()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Members"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = view.center
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func filterMembers(searchText: String) {
        filteredMemberSearch = members.filter({ (member: Member) -> Bool in
            return (member.name?.first.lowercased().contains(searchText.lowercased()) ?? false ||
                member.name?.last.lowercased().contains(searchText.lowercased()) ?? false
            )
        })
        self.membersTableView.reloadData()
    }
    
    func getMemberData(index: Int) -> Member {
        if isSearching {
            return filteredMemberSearch[index]
        } else {
            return members[index]
        }
    }
    
    @objc func onSortClicked() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC: MemberFilterViewController = storyBoard.instantiateViewController(identifier: "memberFilterVC")
        filterVC.sortDelegate = self
        filterVC.selectedSortOrder = sortOrder
        filterVC.selectedSortType = sortType
        navigationController?.present(filterVC, animated: true, completion: nil)
    }
    
    func sortMembers(sortOrder: SortOrder, sortType: SortType) {
        if sortType == .byName {
            if sortOrder == .ascending {
                members.sort(by: {$0.name?.first ?? "" < $1.name?.first ?? ""})
            } else {
                members.sort(by: {$0.name?.first ?? "" > $1.name?.first ?? ""})
            }
        } else {
            if sortOrder == .ascending {
                members.sort(by: {$0.age ?? 0 < $1.age ?? 0})
            } else {
                members.sort(by: {$0.age ?? 0 > $1.age ?? 0})
            }
        }
    }
    
    @IBAction func phoneMemberAction(_ sender: UIButton) {
        if let member = getMemberFromSender(sender: sender) {
            if let phoneNumber = member.phone {
                let correctedPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
                if let phoneCallURL: URL = URL(string: "tel://" + correctedPhone) {
                    if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                        UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func mailMemberAction(_ sender: UIButton) {
        if let member = getMemberFromSender(sender: sender) {
            if let emailAddress = member.email {
                if let emailURL: URL = URL(string: "mailto:\(emailAddress)") {
                    if (UIApplication.shared.canOpenURL(emailURL)) {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    internal func getMemberFromSender(sender: UIButton) -> Member? {
        guard let membersCell = (sender.superview?.superview?.superview as? MembersTableViewCell) else { return nil }
        guard let indexPath = membersTableView.indexPath(for: membersCell) else { return nil }
        return getMemberData(index: indexPath.row)
    }
}

extension MembersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredMemberSearch.count
        } else {
            return members.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MembersTableViewCell
        let member = getMemberData(index: indexPath.row)
        if let memberName = member.name {
            cell.name.text = memberName.first + " " + memberName.last
        } else {
            cell.name.text = ""
        }
        let age:Int = member.age != nil ? member.age! : 0
        let ageInString: String = age != 0 ? String(age) : ""
        cell.age.text = "Age:" + " " + ageInString + " " + "years"
        if partOfOneCompany {
            cell.company.isHidden = true
        } else {
            cell.company.text = "Company:" + " " + (member.companyName ?? "")
        }
        if DataManager.shared.isMemberFavorite(memberId: member.id ?? "") {
            cell.favoriteImage.isHidden = false
        } else {
            cell.favoriteImage.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if partOfOneCompany {
            return 100
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = self.contextualToggleFavoriteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [favoriteAction])
        return swipeConfig
    }
    
    func contextualToggleFavoriteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let member = getMemberData(index: indexPath.row)
        let isFavorite = DataManager.shared.isMemberFavorite(memberId: member.id ?? "")
        var title = "Favorite"
        if isFavorite {
            title = "Remove " + title
        } else {
            title = "Set " + title
        }
        let action = UIContextualAction(style: .normal, title: title) { (UIContextualAction, view, completionHandler: (Bool) -> Void) in
            if member.id != nil {
                DataManager.shared.udpateMemberFavorite(isFavorite: !isFavorite,memberId: member.id!)
                self.membersTableView.reloadRows(at: [indexPath], with: .none)
            }
            completionHandler(true)
        }
        if isFavorite {
            action.image = UIImage(systemName: "star.fill")
            action.backgroundColor = UIColor.red
        } else {
            action.image = UIImage(systemName: "star")
            action.backgroundColor = UIColor.systemGreen
        }
        return action
    }
}

extension MembersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterMembers(searchText: searchBar.text!)
    }
}

extension MembersViewController: MemberSortDelegate {
    func didUpdateSort(sortBy: Int, sortType: Int) {
        if sortBy == 0 {
            self.sortOrder = .ascending
        } else {
            self.sortOrder = .descending
        }

        if sortType == 0 {
            self.sortType = .byName
        } else {
            self.sortType = .byAge
        }
        sortMembers(sortOrder: self.sortOrder, sortType: self.sortType)
        self.membersTableView.reloadData()
    }
}

extension MembersViewController: MembersData {
    func didReceiveMembersData() {
        DataManager.shared.membersDataDelegate = nil
        members = DataManager.shared.getAllMembers()
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if self.members.count > 0 {
                self.setupMembersView()
            } else {
                //Display No Members Data
            }
        }
    }
}
