//
//  NetworkActivityLogger.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Alamofire

/// The level of logging detail.
public enum NetworkActivityLoggerLevel {
    /// Do not log requests or responses.
    case off
    
    /// Logs HTTP method, URL, header fields, & request body for requests, and status code, URL, header fields, response string, & elapsed time for responses.
    case debug
    
    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses.
    case info
    
    /// Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses, but only for failed requests.
    case warn
    
    /// Equivalent to `.warn`
    case error
    
    /// Equivalent to `.off`
    case fatal
}

/// `NetworkActivityLogger` logs requests and responses made by Alamofire.SessionManager, with an adjustable level of detail.
public class NetworkActivityLogger {
    // MARK: - Properties
    
    /// The shared network activity logger for the system.
    public static let shared = NetworkActivityLogger()
    
    /// The level of logging detail. See NetworkActivityLoggerLevel enum for possible values. .info by default.
    public var level: NetworkActivityLoggerLevel
    
    /// Omit requests which match the specified predicate, if provided.
    public var filterPredicate: NSPredicate?
    
    private var startDates: [URLSessionTask: Date]
    
    // MARK: - Internal - Initialization
    
    init() {
        level = .info
        startDates = [URLSessionTask: Date]()
    }
    
    deinit {
        stopLogging()
    }
    
    // MARK: - Logging
    
    /// Start logging requests and responses.
    public func startLogging() {
        stopLogging()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkActivityLogger.networkRequestDidStart(notification:)),
            name: Notification.Name.Task.DidResume,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(NetworkActivityLogger.networkRequestDidComplete(notification:)),
            name: Notification.Name.Task.DidComplete,
            object: nil
        )
    }
    
    /// Stop logging requests and responses.
    public func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private - Notifications
    
    @objc private func networkRequestDidStart(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        startDates[task] = Date()
        
        switch level {
        case .debug:
            logDivider()
            
            debugPrint("\(httpMethod) '\(requestURL.absoluteString)':")
            
            if let httpHeadersFields = request.allHTTPHeaderFields {
                logHeaders(headers: httpHeadersFields)
            }
            
            if let httpBody = request.httpBody, let httpBodyString = String(data: httpBody, encoding: .utf8) {
                print(httpBodyString)
            }
        case .info:
            logDivider()
            
            debugPrint("\(httpMethod) '\(requestURL.absoluteString)'")
        default:
            break
        }
    }
    
    @objc private func networkRequestDidComplete(notification: Notification) {
        guard let sessionDelegate = notification.object as? SessionDelegate,
            let userInfo = notification.userInfo,
            let task = userInfo[Notification.Key.Task] as? URLSessionTask,
            let request = task.originalRequest,
            let httpMethod = request.httpMethod,
            let requestURL = request.url
            else {
                return
        }
        
        if let filterPredicate = filterPredicate, filterPredicate.evaluate(with: request) {
            return
        }
        
        var elapsedTime: TimeInterval = 0.0
        
        if let startDate = startDates[task] {
            elapsedTime = Date().timeIntervalSince(startDate)
            startDates[task] = nil
        }
        
        if let error = task.error {
            switch level {
            case .debug, .info, .warn, .error:
                logDivider()
                
                debugPrint("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                debugPrint(error)
            default:
                break
            }
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                return
            }
            
            switch level {
            case .debug:
                logDivider()
                
                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                
                logHeaders(headers: response.allHeaderFields)
                
                guard let data = sessionDelegate[task]?.delegate.data else { break }
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                } catch {
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print(string)
                    }
                }
            case .info:
                logDivider()
                
                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")
            default:
                break
            }
        }
    }
}

private extension NetworkActivityLogger {
    func logDivider() {
        print("---------------------")
    }
    
    func logHeaders(headers: [AnyHashable : Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
}
