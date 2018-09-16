//
//  NetworkManager.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/15/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import UIKit

protocol SessionTask {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession : SessionTask { }

protocol ErrorChecker {
    func isRequestSuccessful(error: Error?) -> Bool
}

protocol NetworkHTTPCall {
    /// This is callback, called when network operation is completed. It will have 3 values, success, response and error.
    /// - Parameter success: a Boolean. It will tell you if api call is successful.
    /// - Parameter response: a dictionary, will be containing values for getting from the api response.
    /// Look for key `data` if you are expecting a data to be loaded.
    /// Look for key `headers` if you are looking for headers of the request.
    /// Look for key `mimeType` if you want for mimeType of the data received.
    /// - Parameter error: an error object returned if we get problem while processing request.
    typealias NetworkCompletion = (_ success: Bool,_ response: [String: Any?], _ error: Error?) -> Void
    
    func getAPIResponse(for url: URL, callBack: NetworkCompletion?)
    
    func postAPIResponse(for url: URL, postBody: Data, callBack: NetworkCompletion?)
    
    
    func getSecurityHeaders() -> [String: String]
    
    func isRequestSuccessful(error: Error?) -> Bool
}

extension NetworkHTTPCall {
    
    func getAPIResponse(for url: URL, callBack: NetworkCompletion?) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        // Adding headers to the request
        let headers = getSecurityHeaders()
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let success = self.isRequestSuccessful(error: error)
            let responseDict = self.getDictionary(for: data, response: response)
            callBack?(success, responseDict, error)
        }
        task.resume()
    }
    
    func postAPIResponse(for url: URL, postBody: Data, callBack: NetworkCompletion?) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        // Adding headers to the request
        let headers = getSecurityHeaders()
        
        request.httpBody = postBody
        
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let success = self.isRequestSuccessful(error: error)
            let responseDict = self.getDictionary(for: data, response: response)
            callBack?(success, responseDict, error)
        }
        task.resume()
    }
    
    func getHeaders(from url: URL, callBack: NetworkCompletion?) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "HEAD"
        
        // Adding headers to the request
        let headers = getSecurityHeaders()
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let success = self.isRequestSuccessful(error: error)
            let responseDict = self.getDictionary(for: data, response: response)
            callBack?(success, responseDict, error)
        }
        task.resume()
    }
    
    func getSecurityHeaders() -> [String: String] {
        return [:]
    }
    
    /// Check if error object is nil
    ///
    /// - Parameter error: error while performing task.
    /// - Returns: true of successful otherwise false.
    func isRequestSuccessful(error: Error?) -> Bool {
        if error != nil {
            return false
        }
        return true
    }
    
    /// Get the dictionary of the data and response. This will provide you the dictionary having important fields that you might be using for further processing.
    ///
    /// - Parameters:
    ///   - data: recieved data from the API call
    ///   - response: received response from API ( mainly for the headers and status code )
    /// - Returns:  a mapped dictionary having important fields
    private func getDictionary(for data: Data?, response: URLResponse?) -> [String: Any?] {
        var responseDict : [String: Any?] = [:]
        responseDict["data"] = data
        responseDict["mimeType"] = response?.mimeType
        responseDict["url"] = response?.url
        responseDict["headers"] = (response as? HTTPURLResponse)?.allHeaderFields
        responseDict["statusCode"] = (response as? HTTPURLResponse)?.statusCode
        return responseDict
    }
}
