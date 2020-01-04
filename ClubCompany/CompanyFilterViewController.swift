//
//  CompanyFilterViewController.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Nagravision. All rights reserved.
//

import UIKit

class CompanyFilterViewController: UIViewController {

    @IBOutlet weak var sortTableView: UITableView!
    var sortTypes: [String] = ["Default sort (Actual result)", "Ascending", "Descending"]
    var selectedSort: Int = 0
    weak var sortDelegate: CompanyViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        sortTableView.delegate = self
        sortTableView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTouch))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTouch() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CompanyFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CompanySortTableViewCell = tableView.dequeueReusableCell(withIdentifier: "sortCell") as! CompanySortTableViewCell
        cell.textLabel?.text = sortTypes[indexPath.row]
        if selectedSort == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSort = indexPath.row
        sortDelegate?.selectedSort(sortIndex: selectedSort)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
}
