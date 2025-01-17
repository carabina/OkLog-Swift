//
//  LogData.swift
//  OkLog
//
//  Created by Diego Trevisan Lara on 04/07/2018.
//

import Foundation
import Gzip
import SwiftProtobuf

extension LogData {
    
    init(request: URLRequest?, response: URLResponse?, data: Data?, firedAt: Date?) {
        
        // Request Data
        if let request = request {
            requestFailed = false
            requestURL = request.url?.absoluteString ?? ""
            requestMethod = request.httpMethod ?? ""
            `protocol` = request.url?.scheme ?? ""
            requestContentLength = Int64(request.httpBody?.count ?? 0)
            requestHeaders = request.allHTTPHeaderFields?.headerData ?? []
        } else {
            requestFailed = true
        }
        
        // Response Data
        if let response = response as? HTTPURLResponse {
            responseCode = Int32(response.statusCode)
            responseMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            responseContentLength = response.expectedContentLength
            responseBodySize = Int64(data?.count ?? 0)
            responseURL = response.url?.absoluteString ?? ""
            
            if let firedAt = firedAt {
                responseDurationMs = Int64(Date().timeIntervalSince(firedAt) * 1000)
            }
            
            if let allHeaderFields = response.allHeaderFields as? [String: String] {
                responseHeaders = allHeaderFields.headerData
            }
        }
    }
    
    func safeEncoded() -> String? {
        return try? serializedData().safeEncoded()
    }
    
}
