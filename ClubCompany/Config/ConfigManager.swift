//
//  ConfigManager.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import Foundation

public class ConfigManager: NSObject {
    public static let shared = ConfigManager()
    private override init() {}

    private var selectedScheme:String = "http"
    private var platformURL: String = ""
    private var isSecurityEnabled: Bool = false
    
    func getScheme() -> String {
        return selectedScheme
    }
    
    func getHostURL() -> String {
        return platformURL
    }
    
    public func setSecurityRequired(status: Bool) {
        isSecurityEnabled = status
        if isSecurityEnabled {
            selectedScheme = "https"
        } else {
            selectedScheme = "http"
        }
    }
    
    public func setHostURL(baseURL: String) {
        platformURL = baseURL
    }
    
    func getContentType() -> String {
        return "application/json"
    }
}
