//
//  ModelClass.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import Foundation

public struct Member: Codable {
    let id: String?
    let age: Int?
    let name: PersonName?
    let email: String?
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case age
        case name
        case email
        case phone
    }
}

public struct PersonName: Codable {
    var first: String { return _first ?? "" }
    var last: String { return _last ?? "" }
    
    private var _first: String?
    private var _last: String?
    
    enum CodingKeys: String, CodingKey {
        case _first = "first"
        case _last = "last"
    }
}

public struct CompanyInfo: Codable {
    let id: String?
    var company: String { return _companyName ?? "Name unavailable" }
    let website: String?
    let logo: String?
    let about: String?
    let members: [Member]?
    
    private var _companyName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case _companyName = "company"
        case website
        case logo
        case about
        case members
    }
}

extension CompanyInfo {
  static func getCompanyInfo() -> [CompanyInfo] {
    guard
      let url = Bundle.main.url(forResource: "response", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([CompanyInfo].self, from: data)
    } catch {
      return []
    }
  }
}
