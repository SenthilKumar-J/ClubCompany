//
//  NetworkRequestManager.swift
//  ClubCompany
//
//  Created by Senthil Kumar J on 04/01/20.
//  Copyright © 2020 Senthil Kumar J. All rights reserved.
//

import Foundation
import UIKit

let clubURL = "next.json-generator.com"
internal let requestClubURL = "/api/json/get/Vk-LhK44U"

enum RequestType: String {
    case GET = "GET"
    case POST = "POST"
}

enum PlaceHolderType: String {
    case defaultPoster = "companyDefaultLogo"
}

public var imageCache = NSCache<NSString, NSData>()

typealias completionHandler = (Data?, URLResponse?, Error?) -> Void
let serialQueue = DispatchQueue(label: "serialImageQueue")

class NetworkRequestManager {
    
    func executeRequest(request: URLRequest, completion: @escaping completionHandler) {
        //create the session object
        let session = URLSession.shared
        
        print("NetworkRequestManager | URL:", request.url?.absoluteString ?? "")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            completion(data, response, error)
        })
        
        task.resume()
    }
}

class PosterImageView: UIImageView {
    
    var imagePosterUrlString:String?
    
    func loadImagesUsingLocalCache(imageURL : String?) {
        
        imagePosterUrlString = imageURL
        
        //Set the default image to load before initiating download
        self.image = UIImage(named: PlaceHolderType.defaultPoster.rawValue)
        
        // if not, download image from url
        if (imageURL != "" && imageURL != nil) {
            // check cached image
            if let cachedImageData = imageCache.object(forKey: imageURL! as NSString) {
                DispatchQueue.global(qos: .background).async {
                    if let UIImageData = UIImage(data: Data(referencing: cachedImageData)) {
                        DispatchQueue.main.async {
                            self.image = UIImageData
                        }
                    }
                }
                return
            }
            
            // if not available in cache, download image from url
            let url = URL(string: imageURL!)
            if url == nil {
                return
            }
            
            ImageTaskManager.shared.downloadImageTask(with: url!) { [weak self] (data, response, error) in
                if error != nil {
                    print("PosterImageView | Error in fetching image:", error!.localizedDescription as Any)
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if data != nil {
                        let imageData:NSData? = NSData(data: data!)
                        if imageData != nil {
                            if let fetchedImageURL = httpResponse.url?.absoluteString {
                                imageCache.setObject(imageData!, forKey: fetchedImageURL as NSString)
                            }
                            guard let strongSelf = self else { return }
                            DispatchQueue.global(qos: .background).async {
                                if strongSelf.imagePosterUrlString == imageURL {
                                    if let UIImageData = UIImage(data: data!) {
                                        DispatchQueue.main.async {
                                            strongSelf.image = UIImageData
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

class ImageTaskManager {
    static let shared = ImageTaskManager()
    
    let session = URLSession(configuration: .default)
    
    var dataTasks:[String: [completionHandler]] = [:]
    
    func downloadImageTask(with url: URL, completion: @escaping completionHandler) {
        serialQueue.async {
            self.downloadImageTaskInSerialAsync(with: url, completion: completion)
        }
    }
    
    internal func downloadImageTaskInSerialAsync(with url: URL, completion: @escaping completionHandler) {
        //Check if the image is already downloading, then append the caller's completion block to the URL
        if dataTasks.keys.contains(url.absoluteString) {
            guard dataTasks[url.absoluteString] != nil else {
                //Once session task is completed, remove the URL from the dataTasks.
                if ImageTaskManager.shared.dataTasks.keys.contains(url.absoluteString) {
                    ImageTaskManager.shared.dataTasks.removeValue(forKey: url.absoluteString)
                }
                return
            }
            dataTasks[url.absoluteString]?.append(completion)
        } else {
            dataTasks[url.absoluteString] = [completion]
            let sessionTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                serialQueue.async {
                    if(response != nil && data != nil) {
                        let httpResponse = response as? HTTPURLResponse
                        let statusCode = httpResponse?.statusCode
                        
                        switch statusCode {
                        case 200:
                            guard let dataCompletionHandlers = self.dataTasks[url.absoluteString] else { return }
                            
                            //Once session task is completed, remove the URL from the dataTasks.
                            if ImageTaskManager.shared.dataTasks.keys.contains(url.absoluteString) {
                                ImageTaskManager.shared.dataTasks.removeValue(forKey: url.absoluteString)
                            }
                            
                            //Call all the completionHandlers for that URL
                            for handler in dataCompletionHandlers {
                                handler(data, response, error)
                            }
                        default:
                            guard let dataCompletionHandlers = ImageTaskManager.shared.dataTasks[url.absoluteString] else { return }
                            
                            //Call all the completionHandlers for that URL
                            for handler in dataCompletionHandlers {
                                handler(data, response, error)
                            }
                            
                            //Once session task is completed, remove the URL from the dataTasks.
                            if self.dataTasks.keys.contains(url.absoluteString) {
                                self.dataTasks.removeValue(forKey: url.absoluteString)
                            }
                        }
                    }
                }
            })
            sessionTask.resume()
        }
    }
}
