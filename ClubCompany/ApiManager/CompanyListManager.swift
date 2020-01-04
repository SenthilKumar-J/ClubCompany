//
//  CompanyListManager.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Nagravision. All rights reserved.
//

import Foundation

public protocol CompanyListDelegate: AnyObject {
    func didCompanyListUpdate(data: [CompanyInfo])
    func onCompanyListError(error: Error?)
}

public class CompanyListManager: NSObject {
    
    internal var companyList: [CompanyInfo] = []
    weak var companyDelegate: CompanyListDelegate?
    
    public func getCompanyList(callBack: CompanyListDelegate?) {
        companyDelegate = callBack
        var urlComponents = URLComponents()
        urlComponents.scheme = ConfigManager.shared.getScheme()
        urlComponents.host = ConfigManager.shared.getHostURL()
        urlComponents.path = requestClubURL
        
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: urlComponents.url!)
        
        request.httpMethod = RequestType.GET.rawValue
        request.timeoutInterval = 10
        
        request.addValue(ConfigManager.shared.getContentType(), forHTTPHeaderField: "Content-Type")
        
        NetworkRequestManager().executeRequest(request: request) { (data, response, error) in
            self.handleReceivedCompanyData(data: data, response: response, error: error)
        }
    }
    
    func handleReceivedCompanyData(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            if let delegate = companyDelegate {
                delegate.onCompanyListError(error: error)
            }
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, data != nil {
            do {
                var clubCompanyResponse: [CompanyInfo]?
                clubCompanyResponse = try JSONDecoder().decode([CompanyInfo].self, from: data!)
                if clubCompanyResponse != nil && !clubCompanyResponse!.isEmpty {
                    extractCompanyClubInfo(response: clubCompanyResponse!)
                } else {
                    if let delegate = companyDelegate {
                        delegate.onCompanyListError(error: nil)
                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
                if let delegate = companyDelegate {
                    delegate.onCompanyListError(error: error)
                }
            }
        }
    }
    
    func extractCompanyClubInfo(response: [CompanyInfo]) {
        companyDelegate?.didCompanyListUpdate(data: response)
    }
}

