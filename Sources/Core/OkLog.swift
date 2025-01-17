//
//  OkLog.swift
//  OkLog
//
//  Created by Diego Trevisan Lara on 28/06/18.
//  Copyright © 2018 Diego Trevisan Lara. All rights reserved.
//

import Foundation

public protocol IOkLog {
    static func willSend(_ request: URLRequest)
    static func log(request: URLRequest?, response: URLResponse?, data: Data?, shortenUrl: Bool)
    static func getUrl(request: URLRequest?, response: URLResponse?, data: Data?, shortenUrl: Bool) -> String
}

public class OkLog: IOkLog {
    
    public static func willSend(_ request: URLRequest) {
        FireDateBucket.storeFireDate(for: request)
    }
    
    public static func log(request: URLRequest?, response: URLResponse?, data: Data?, shortenUrl: Bool = true) {
        print(getUrl(request: request, response: response, data: data, shortenUrl: shortenUrl))
    }
    
    public static func getUrl(request: URLRequest?, response: URLResponse?, data: Data?, shortenUrl: Bool = true) -> String {
        
        let logData = LogData(request: request, response: response, data: data, firedAt: FireDateBucket.getFireDate(request))
        let requestBody = request?.httpBody?.safeEncoded()
        let responseBody = data?.safeEncoded() ?? "0"
        
        var components = [String: Any]()
        components["qb"] = requestBody
        components["d"] = logData.safeEncoded()
        components["s"] = shortenUrl ? 1 : 0
        
        let url = "\(Constants.urlBaseRemote)\(Constants.urlBasePath)\(Constants.urlInfoPath)\(responseBody)?\(components.queryString)"
        return url
    }
    
}

private class FireDateBucket {
    
    private static var fireDates = [Int: Date]()
    
    static func storeFireDate(for request: URLRequest?) {
        guard let hashValue = request?.hashValue else {
            return
        }
        
        fireDates[hashValue] = Date()
    }
    
    static func getFireDate(_ request: URLRequest?) -> Date? {
        guard let hashValue = request?.hashValue, let date = fireDates.removeValue(forKey: hashValue) else {
            return nil
        }
        
        return date
    }
    
}
