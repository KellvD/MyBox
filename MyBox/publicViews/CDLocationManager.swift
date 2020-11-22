//
//  CDLocationManager.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit
import CoreLocation
class CDLocationManager: NSObject,CLLocationManagerDelegate {

    var location:CLLocation!
    var cityName:String!
    
    
    private var locationManager:CLLocationManager!
    
    static let shared = CDLocationManager()
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1000.0
        locationManager.delegate = self
    }
    
    
    func startLocation(){
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first!
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil{
                placemarks?.forEach({ (place) in
                    self.cityName = place.locality!
                })
            }
        }
    }
}
