//
//  NetworkManager.swift
//  iOS-Library
//
//  Created by Shailesh Aher on 9/15/18.
//  Copyright © 2018 Shailesh Aher. All rights reserved.
//

import UIKit


public protocol NetworkHTTPCall {
    /// This is callback, called when network operation is completed. It will have 3 values, success, response and error.
    /// - Parameter success: a Boolean. It will tell you if api call is successful.
    /// - Parameter response: a dictionary, will be containing values for getting from the api response.
    /// Look for key `data` if you are expecting a data to be loaded.
    /// Look for key `headers` if you are looking for headers of the request.
    /// Look for key `mimeType` if you want for mimeType of the data received.
    /// - Parameter error: an error object returned if we get problem while processing request.
    typealias NetworkCompletion = (_ success: Bool,_ response: Response?, _ error: Error?) -> Void
    
    func getAPIResponse(for url: URL, callBack: NetworkCompletion?)
    
    func postAPIResponse(for url: URL, postBody: Data, callBack: NetworkCompletion?)
    
    
    func getSecurityHeaders() -> [String: String]
    
    func isRequestSuccessful(error: Error?) -> Bool
}

public extension NetworkHTTPCall {
    
    /// This will call API with `GET` method. You will callBack when API hit successfully 3 values, success, response and error.
    /// - Parameter success: a Boolean. It will tell you if api call is successful.
    /// - Parameter response: a dictionary, will be containing values for getting from the api response.
    /// Look for key `data` if you are expecting a data to be loaded.
    /// Look for key `headers` if you are looking for headers of the request.
    /// Look for key `mimeType` if you want for mimeType of the data received.
    /// - Parameter error: an error object returned if we get problem while processing request.
    func getAPIResponse(for url: URL, callBack: NetworkCompletion?) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        // Adding headers to the request
        let headers = getSecurityHeaders()
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let success = self.isRequestSuccessful(error: error)
            let response = self.getResponse(for: data, response: response)
            callBack?(success, response, error)
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
            let response = self.getResponse(for: data, response: response)
            callBack?(success, response, error)
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
            let response = self.getResponse(for: data, response: response)
            callBack?(success, response, error)
        }
        task.resume()
    }
    
    /// Provide your custom headers in this method.
    ///
    /// - Returns: Will need header dictionary.
    func getSecurityHeaders() -> [String: String] {
        return [:]
    }
    
    /// Check if error object is nil, you can customize this error checking by implementing this method
    ///
    /// - Parameter error: error while performing task.
    /// - Returns: true of successful otherwise false.
    func isRequestSuccessful(error: Error?) -> Bool {
        return error == nil
    }
    
    private func getResponse(for data: Data?, response: URLResponse?) -> Response? {
        let dict = getDictionary(response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.headerFormat)
        do {
            var response : Response? = try decoder.decode(dict: dict)
            response?.data = data
            return response
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Get the dictionary of the data and response. This will provide you the dictionary having important fields that you might be using for further processing.
    ///
    /// - Parameters:
    ///   - data: recieved data from the API call
    ///   - response: received response from API ( mainly for the headers and status code )
    /// - Returns:  a mapped dictionary having important fields
    private func getDictionary(response: URLResponse?) -> [String: Any] {
        var responseDict = ((response as? HTTPURLResponse)?.allHeaderFields as? [String : Any]) ?? [:]
        responseDict["mimeType"] = response?.mimeType
        responseDict["url"] = response?.url?.absoluteString
        responseDict["statusCode"] = (response as? HTTPURLResponse)?.statusCode
        return responseDict
    }
}

public protocol URLBuilder {
    func buildURL(with destination: String, pathParam array: [String], andQuery queryDict: [String: String]) -> URL?
}

public extension URLBuilder {
    
    func buildURL(with destination: String, pathParam array: [String], andQuery queryDict: [String: String]) -> URL? {
        guard !destination.isEmpty else { return nil }
        var urlString = destination
        urlString += getPathParamString(from: array)
        urlString += getQueryString(from: queryDict)
        return URL(string: urlString)
    }
    
    private func getQueryString(from dictionary: [String: String]) -> String {
        guard !dictionary.isEmpty else { return "" }
        var queryString = "?"
        queryString += dictionary.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return queryString
    }
    
    private func getPathParamString(from array: [String]) -> String {
        guard !array.isEmpty else { return "" }
        return "/" + array.joined(separator: "/")
    }
}

public struct Response : Decodable {
    public var expires: Date?
    public var server: String?
    public var age: String?
    public var length: String?
    public var mimeType: String?
    public var url: URL?
    public var lastModified: Date?
    public var date: Date?
    public var contentType: String?
    public var statusCode: Int?
    public var data: Data?
    
    enum CodingKeys: String, CodingKey {
        case c = "Expires"
        case server = "Server"
        case age = "Age"
        case length = "Content-Length"
        case lastModified = "Last-Modified"
        case date = "Date"
        case contentType = "Content-Type"

        case mimeType
        case url
        case statusCode
        case data
    }
}

public extension DateFormatter {
    static let headerFormat : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
