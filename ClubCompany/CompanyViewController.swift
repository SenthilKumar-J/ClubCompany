//
//  ViewController.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

protocol SortDelegate: AnyObject {
    func selectedSort(sortIndex: Int)
}

protocol CompanyInfoUpdateDelegate: AnyObject {
    func didUpdateCompanyFavorite(isFavorite: Bool, companyId: String)
    func didUpdateCompanyFollow(isFollow: Bool, companyId: String)
}

class CompanyViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var companyTableView: UITableView!
    
    //MARK:- Variables
    var companyResponse: [CompanyInfo] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCompanySearch: [CompanyInfo] = []
    var activityIndicator: UIActivityIndicatorView! = nil
    var sortedType: Int = 0
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    //MARK:- View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Company"
        navigationController?.navigationBar.prefersLargeTitles = true
        let rightButton = UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: self, action: #selector(onFilterClicked))
        navigationItem.rightBarButtonItem = rightButton
        setupActivityIndicator()
        companyTableView.isHidden = true
        CompanyListManager().getCompanyList(callBack: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    //MARK:- View Methods
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = view.center
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func reloadAndShowTableView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.companyTableView.delegate = self
            self.companyTableView.dataSource = self
            self.companyTableView.reloadData()
            self.companyTableView.isHidden = false
            self.setupSearchBar()
        }
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Companies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterCompany(searchText: String) {
        filteredCompanySearch = companyResponse.filter({ (companyInfo: CompanyInfo) -> Bool in
            return companyInfo.company.lowercased().contains(searchText.lowercased())
        })
        self.companyTableView.reloadData()
    }
    
    func getCompanyData(index: Int) -> CompanyInfo {
        if isSearching {
            return filteredCompanySearch[index]
        } else {
            return companyResponse[index]
        }
    }
    
    @objc func onFilterClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC: CompanyFilterViewController = storyBoard.instantiateViewController(identifier: "compFilterVC")
        filterVC.sortDelegate = self
        filterVC.selectedSort = sortedType
        navigationController?.present(filterVC, animated: true, completion: nil)
    }
}

//MARK:- Extensions
extension CompanyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredCompanySearch.count
        } else {
            return companyResponse.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CompanyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "companyCell", for: indexPath) as! CompanyTableViewCell
        let companyData = getCompanyData(index: indexPath.row)
        cell.companyLogo.loadImagesUsingLocalCache(imageURL: companyData.logo)
        cell.companyName.text = companyData.company
        cell.companyTotalMembers.text = "\(companyData.members?.count ?? 0) Members"
        cell.companyTotalMembers.textColor = .systemBlue
        if DataManager.shared.isCompanyFavorite(companyId: companyData.id!) {
            cell.favoriteImage.isHidden = false
        } else {
            cell.favoriteImage.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let companyInfoVC: CompanyInfoViewController = storyBoard.instantiateViewController(identifier: "companyInfoVC")
        companyInfoVC.companyInfo = getCompanyData(index: indexPath.row)
        companyInfoVC.companyInfoDelegate = self
        companyInfoVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(companyInfoVC, animated: true)
    }
}

extension CompanyViewController: CompanyListDelegate {
    func didCompanyListUpdate(data: [CompanyInfo]) {
        print("Received Company Data update")
        companyResponse = data
        reloadAndShowTableView()
        DataManager.shared.setCompanyResponse(response: data)
    }
    
    func onCompanyListError(error: Error?) {
        companyResponse = []
        reloadAndShowTableView()
        DataManager.shared.setCompanyResponse(response: [])
    }
}

extension CompanyViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterCompany(searchText: searchBar.text!)
    }
}

extension CompanyViewController: SortDelegate {
    func selectedSort(sortIndex: Int) {
        sortedType = sortIndex
        if sortIndex == 0 {
            companyResponse = DataManager.shared.actualCompanyResponse
        } else if sortIndex == 1 {
            companyResponse.sort(by: {$0.company < $1.company})
        } else {
            companyResponse.sort(by: {$0.company > $1.company})
        }
        
        self.companyTableView.reloadData()
    }
}

extension CompanyViewController: CompanyInfoUpdateDelegate {
    func didUpdateCompanyFavorite(isFavorite: Bool, companyId: String) {
        DataManager.shared.updateFavorite(isFavorite: isFavorite, companyId: companyId)
        self.companyTableView.reloadData()
    }
    
    func didUpdateCompanyFollow(isFollow: Bool, companyId: String) {
        DataManager.shared.updateFollowingList(isFollow: isFollow, companyId: companyId)
        self.companyTableView.reloadData()
    }
    
    
}

