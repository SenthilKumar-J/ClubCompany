//
//  DataManager.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import Foundation

public class DataManager: NSObject {
    public static let shared = DataManager()
    private override init() {}
    
    var favoriteIds: [String] = []
    var followingIds: [String] = []
    var actualCompanyResponse: [CompanyInfo] = []
    
    func setCompanyResponse(response: [CompanyInfo]) {
        actualCompanyResponse = response
    }
    
    func updateFavorite(isFavorite: Bool, companyId: String) {
        if isFavorite {
            if !(favoriteIds.contains(companyId)) {
                favoriteIds.append(companyId)
            }
        } else {
            if let index = favoriteIds.firstIndex(of: companyId) {
                favoriteIds.remove(at: index)
            }
        }
    }
    
    func updateFollowingList(isFollow: Bool, companyId: String) {
        if isFollow {
            if !(followingIds.contains(companyId)) {
                followingIds.append(companyId)
            }
        } else {
            if let index = followingIds.firstIndex(of: companyId) {
                followingIds.remove(at: index)
            }
        }
    }
    
    func isCompanyFavorite(companyId: String) -> Bool {
        return favoriteIds.contains(companyId)
    }
    
    func isFollowing(companyId: String) -> Bool {
        return followingIds.contains(companyId)
    }
}
