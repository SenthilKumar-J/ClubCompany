//
//  MemberFilterViewController.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 05/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import UIKit

enum SortOrder {
    case ascending
    case descending
}

enum SortType {
    case byName
    case byAge
}

class MemberFilterViewController: UIViewController {

    @IBOutlet weak var sortByNameAgeSegment: UISegmentedControl!
    @IBOutlet weak var sortOrderSegment: UISegmentedControl!
    
    @IBOutlet weak var applyButtonOutlet: CustomButton!
    @IBOutlet weak var cancelButtonOutlet: CustomButton!
    weak var sortDelegate: MemberSortDelegate?
    var selectedSortOrder: SortOrder = .ascending
    var selectedSortType: SortType = .byName
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sortByNameAgeSegment.setTitle("Name", forSegmentAt: 0)
        sortByNameAgeSegment.setTitle("Age", forSegmentAt: 1)
        if selectedSortType == .byName {
            sortByNameAgeSegment.selectedSegmentIndex = 0
        } else {
            sortByNameAgeSegment.selectedSegmentIndex = 1
        }
        
        sortOrderSegment.setTitle("Ascending", forSegmentAt: 0)
        sortOrderSegment.setTitle("Descending", forSegmentAt: 1)
        if selectedSortOrder == .ascending {
            sortOrderSegment.selectedSegmentIndex = 0
        } else {
            sortOrderSegment.selectedSegmentIndex = 1
        }
        
        applyButtonOutlet.setShadow()
        applyButtonOutlet.setTitle("Apply", for: .normal)
        cancelButtonOutlet.setShadow()
        cancelButtonOutlet.setTitle("Cancel", for: .normal)
    }
    

    @IBAction func applySortAction(_ sender: Any) {
        sortDelegate?.didUpdateSort(sortBy: sortOrderSegment.selectedSegmentIndex, sortType: sortByNameAgeSegment.selectedSegmentIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelSortAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
