//
//  CloudantViewModel.swift
//  IOTrace
//
//  Created by Aaron Liberatore on 2/14/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import BMSCore
import SwiftyJSON

/// Protocol defining a data receiver
protocol CloudantDataReceiver: class {
    func didReceiveLocations()
    func didReceiveLuminances()
    func showError(_ error: ApplicationError)
}

/// Model containing all the data logic
class CloudantViewModel {
    
    // Data Receiver
    weak var delegate: CloudantDataReceiver?
    
    // Items
    var dateAggregations: [DateAggregator] = []
    
    // The key to start retrieving data from
    private var locationStartKey: String?
    private var luminanceStartKey: String?
    
    // Number of documents to retrieve at a time
    private let block: Int = 200
    
    // Indicates whether the view model has been configured
    private var isConfigured: Bool = false
    
    // Indicates whether the view model is already querying the database
    private var isLoading: Bool = false
    
    // Size of Database
    private var totalEntries: Int = 0
    
    //Cloudant avaiable databases
    private var databases : [CloudantDB]?
    private var locationDBIndex = 0
    private var luminanceDBIndex = 0
    
    private var currentLocationDB : CloudantDB? {
        return databases?[locationDBIndex]
    }
    private var currentLuminanceDB : CloudantDB? {
        if let dbs = databases{
            if luminanceDBIndex < dbs.count {
                return dbs[luminanceDBIndex]
            }
            return nil
        }
        return nil
    }
    
    // Cloudant Endpoint
    private let cloudantURL: URL
    
    // Default Shared session
    private var session: URLSession = URLSession.shared
    
    // Default URLSessionConfiguration
    private var sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
    
    // Logger
    fileprivate let logger = Logger.logger(name: "CloudantClient")
    
    // Initializer
    public init(userId: String, password: String, cloudantURL: URL) {
        
        // Set Credentials
        self.cloudantURL = cloudantURL
        
        // Configure url session authorization
        setupSession(userId: userId, password: password)
        
        // Configure database options
        setupDatabase()
    }
    
    /// MARK: - Public API
    
    // Initiates a network call to retrieve more items from the database
    public func retrieveItems() {
        guard isConfigured, !isLoading else {
            return
        }
        
        isLoading = true
        getLocations()
        getLuminances()
    }
    
    // Number of items in dateAggregations
    public func numberOfItemsIndateAggregations() -> Int {
        return dateAggregations.count
    }
    
    /// MARK: - Configuration
    
    // Configure Session authorization
    private func setupSession(userId: String, password: String) {
        
        // Encode authorization header
        let authStr = userId + ":" + password
        
        // Encode string as base64
        guard let data = authStr.data(using: .utf8)?.base64EncodedString() else {
            logger.error(message: "Could not encode authorization header")
            delegate?.showError(.error("Could not encode authorization header. Please check that your credentials use utf8 encodable charcaters."))
            return
        }
        
        // Append to session
        let authData = "Basic \(data)"
        sessionConfig.httpAdditionalHeaders = ["Authorization": authData]
        self.session = URLSession(configuration: sessionConfig)
    }
    
    // Configure database and field to be used
    private func setupDatabase() {
        
        /// Retrieve an available database
        getCloudantDBNames {
            
            //self.logger.debug(message: "Using the cloudant database: \(currentDB?.name)")
            
            /// Retrieve a field from the database
            
            self.isConfigured = true
            self.retrieveItems()
        }
    }
    
}

/// Extension for database requests
extension CloudantViewModel {
    fileprivate func getLuminances() {
        
        logger.debug(message: "Retrieving documents")
        
        // Ensure we have a database
        guard let db = currentLuminanceDB else {
            self.delegate?.showError(.invalidDatabase)
            return
        }
        
        // Convert url to URLComponents
        guard var queryURL = URLComponents(string: cloudantURL.absoluteString) else {
            logger.error(message: "Could not create URLComponents from cloudantURL")
            self.delegate?.showError(.error("Unable to parse url"))
            return
        }
        
        // Append path and query Items
        queryURL.path = "/" + db.name + "/_design/iotp/_view/luminances-byDate"
        var items = [ URLQueryItem(name: "include_docs", value: "true"),
                      URLQueryItem(name: "limit", value: String(block)),
                      URLQueryItem(name: "descending", value: "true")
        ]
        
        if let key = luminanceStartKey {
            items.append(URLQueryItem(name: "startkey", value: "\"\(key)\""))
            items.append(URLQueryItem(name: "skip", value: String(1)))
        }
        
        queryURL.queryItems = items
        
        // Convert back to URL
        guard let url = queryURL.url else {
            logger.error(message: "Could not create url string from URLComponents")
            self.delegate?.showError(.error("Unable to parse url"))
            return
        }
        
        
        request(url: url) { data in
            self.isLoading = false
            let response = JSON(data)
            
            for item in response["rows"].arrayValue {
                let luminance = LuminanceEvent(json: item["doc"])
                self.addLuminance(luminance)
            }
            
            if let item = response["rows"].arrayValue.last {
                self.luminanceStartKey = item["key"].stringValue
            }
            
            if response["rows"].arrayValue.count == 0 {
                self.delegate?.didReceiveLuminances()
                self.luminanceDBIndex += 1
                self.luminanceStartKey = nil
                self.getLuminances()
            } else {
                self.delegate?.didReceiveLuminances()
                self.getLuminances()
            }
            
        }
    }
    
    func addLuminance(_ luminanceEvent : LuminanceEvent){
        var added = false
        
        for dateAggregation in self.dateAggregations {
            added = dateAggregation.appendLuminance(luminanceEvent)
            if added {
                return
            }
        }
        
        let aggregation = DateAggregator()
        _ = aggregation.appendLuminance(luminanceEvent)
        self.dateAggregations.append(aggregation)
        self.dateAggregations.sort()
        self.dateAggregations.reverse()
    }
    
    // Get items from Cloudant
    fileprivate func getLocations() {
        
        logger.debug(message: "Retrieving documents")
        
        // Ensure we have a database
        guard let db = currentLocationDB else {
            self.delegate?.showError(.invalidDatabase)
            return
        }
        
        // Convert url to URLComponents
        guard var queryURL = URLComponents(string: cloudantURL.absoluteString) else {
            logger.error(message: "Could not create URLComponents from cloudantURL")
            self.delegate?.showError(.error("Unable to parse url"))
            return
        }
        
        // Append path and query Items
        queryURL.path = "/" + db.name + "/_design/iotp/_view/locations-byDate"
        var items = [ URLQueryItem(name: "include_docs", value: "true"),
                      URLQueryItem(name: "limit", value: String(block)),
                      URLQueryItem(name: "descending", value: "true")
        ]
        
        if let key = locationStartKey {
            items.append(URLQueryItem(name: "startkey", value: "\"\(key)\""))
            items.append(URLQueryItem(name: "skip", value: String(1)))
        }
        
        queryURL.queryItems = items
        
        // Convert back to URL
        guard let url = queryURL.url else {
            logger.error(message: "Could not create url string from URLComponents")
            self.delegate?.showError(.error("Unable to parse url"))
            return
        }
        
        request(url: url) { data in
            self.isLoading = false
            let response = JSON(data)
            
            for item in response["rows"].arrayValue {
                let location = LocationEvent(json: item["doc"])
                if location.latitude != 0 && location.longitude != 0{
                    self.addLocation(location)
                }
            }
            
            if let item = response["rows"].arrayValue.last {
                self.locationStartKey = item["key"].stringValue
            }
            
            if response["rows"].arrayValue.count == 0 {
                self.delegate?.didReceiveLocations()
                self.locationDBIndex += 1
                if self.locationDBIndex < self.databases!.count {
                    self.locationStartKey = nil
                    self.getLocations()
                }
            } else {
                self.delegate?.didReceiveLocations()
                self.getLocations()
            }
            
        }
    }
    
    func addLocation(_ location: LocationEvent) {
        var added = false
        
        for dateAggregation in self.dateAggregations {
            added = dateAggregation.appendLocation(location)
            if added {
                return
            }
        }
        
        
        let aggregation = DateAggregator()
        _ = aggregation.appendLocation(location)
        self.dateAggregations.append(aggregation)
        self.dateAggregations.sort()
        self.dateAggregations.reverse()
    }
    
    // Get the first DB name from Cloudant that does not start with a _. Admin permissions are required for this method to work
    fileprivate func getCloudantDBNames(success: @escaping () -> Void) {
        
        logger.debug(message: "Retrieving an available Cloudant Database")
        
        let queryURL = cloudantURL.appendingPathComponent("/_all_dbs")
        
        request(url: queryURL) { data in
            let databaseNames = try? JSONDecoder().decode([String].self, from: data)
            
            self.databases = databaseNames?.compactMap({ name in
                CloudantDB(name: name)
            })
            
            self.databases?.sort()
            self.databases?.reverse()
            
            success()
        }
    }
    
    // Overload to accept url
    private func request(url: URL, success: @escaping (Data) -> Void) {
        request(request: URLRequest(url: url), success: success)
    }
    
    // Helper method to execute requests and parse response
    private func request(request: URLRequest, success: @escaping (Data) -> Void) {
        
        logger.debug(message: "\nRequesting URL: \(String(describing: request.url?.absoluteString ?? ""))")
        
        /// Execute request
        session.dataTask(with: request) { data, _, sessionError in
            
            /// Retrieve data
            guard let data = data, sessionError == nil else {
                let msg = sessionError?.localizedDescription ?? "No data provided from Cloudant"
                self.delegate?.showError(.error(msg))
                return
            }
            
            /// Handle data
            success(data)
            
            }.resume()
    }
    
    /// Helper method to check if a string is nil or empty
    private func checkEmpty(_ str: String?) -> String? {
        if let s = str {
            return s.isEmpty ? nil : s
        }
        return nil
    }
}
