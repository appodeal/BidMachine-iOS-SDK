//
//  SdkContext.swift
//  Sample
//
//  Created by Stas Kochkin on 06/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class AppBehaviourConfiguration {
    var logging = true
    var toast = true
    var location = false
    var callbackLog = true
}

class SdkContext: NSObject {
    private struct Names {
        static let configuration = "BDMSdkConfiguration.txt"
        static let restriction = "BDMUserRestrictions.txt"
        static let sellerId = "SellerID.txt"
        static let appInfo = "AppInfo.txt"
    }
    
    static let shared = SdkContext()
    
    // Base 64 consent string
    public let consentString = "BOQ7WlgOQ7WlgABABwAAABJOACgACAAQABA"
    public var configuration: BDMSdkConfiguration
    public var targeting: BDMTargeting
    public var restriction: BDMUserRestrictions
    public var sellerId: String
    public var appConfiguration: AppBehaviourConfiguration

    private var task: URLSessionDataTask?
    private var locationManager: CLLocationManager?
    
    public var currentLocation: CLLocation? {
        get {
            return locationManager?.location
        }
    }
    
    override init() {
        appConfiguration = AppBehaviourConfiguration()
        configuration = NSKeyedUnarchiver.unarchive(Names.configuration) ?? BDMSdkConfiguration()
        configuration.testMode = true
        targeting = configuration.targeting ?? BDMTargeting()
        restriction = NSKeyedUnarchiver.unarchive(Names.restriction) ?? BDMUserRestrictions()
        sellerId = UserDefaults.standard.object(forKey: Names.sellerId).map { $0 as! String } ?? "1"

        super.init()
    }
    
    public func synchronise() {
        if (appConfiguration.location) {
            startReceivingLocationChanges()
        }
    
        configuration.targeting = targeting
        NSKeyedArchiver.archive(configuration, Names.configuration)
        NSKeyedArchiver.archive(restriction, Names.restriction)
        UserDefaults.standard.set(sellerId, forKey: Names.sellerId)
        BDMSdk.shared().restrictions = restriction
    }
    
    private func startReceivingLocationChanges() {
        locationManager = CLLocationManager()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            locationManager!.requestWhenInUseAuthorization()
        }
        
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        // Configure and start the service.
        locationManager!.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager!.distanceFilter = 100.0  // In meters.
        locationManager!.startUpdatingLocation()
    }
}

extension NSKeyedUnarchiver {
    class func unarchive<T:NSCoding>(_ name:String) -> T? {
        var model: T?
        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending(name))
        do {
            let data = try Data(contentsOf: url)
            if #available(iOS 11.0, *) {
                model = try unarchivedObject(ofClasses: [T.self], from: data) as? T
            } else {
                // Fallback on earlier versions
            }
        } catch {
            return nil
        }
        return model
    }
}

extension NSKeyedArchiver {
    class func archive<T:NSCoding>(_ object:T, _ name:String) {
        let path = NSTemporaryDirectory().appending(name)
        var data: Data?
        do {
            if #available(iOS 11.0, *) {
                data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            } else {
                // Fallback on earlier versions
            }
            try data?.write(to: URL(fileURLWithPath: path))
        } catch {
            print("Couldn't write file")
        }
    }
}

extension NSKeyedUnarchiver {
    class func unarchiveCodable<T:Codable>( _ name:String) ->T? {
        var model: T?
        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending(name))
        do {
            let data = try Data(contentsOf: url)
            if #available(iOS 11.0, *) {
                model = try JSONDecoder().decode(T.self, from: data)
            } else {
                // Fallback on earlier versions
            }
        } catch {
            return nil
        }
        return model
    }
}

extension NSKeyedArchiver {
    class func archiveCodable<T:Codable>(_ object:T, _ name:String) {
        let path = NSTemporaryDirectory().appending(name)
        var data: Data?
        do {
            if #available(iOS 11.0, *) {
                data = try JSONEncoder().encode(object)
            } else {
                // Fallback on earlier versions
            }
            try data?.write(to: URL(fileURLWithPath: path))
        } catch {
            print("Couldn't write file")
        }
    }
}

