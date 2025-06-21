//
//  MapViewController.swift
//  Lab9
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    let branches = [
        Branch(name: "Отделение 1", coordinate: CLLocationCoordinate2D(latitude: 53.9, longitude: 27.5667)),
        Branch(name: "Отделение 2", coordinate: CLLocationCoordinate2D(latitude: 53.91, longitude: 27.55)),
        Branch(name: "Отделение 3", coordinate: CLLocationCoordinate2D(latitude: 53.92, longitude: 27.57))
    ]
    
    private var didShowNearestBranchAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.accessibilityIdentifier = "MapView"
        view.addSubview(mapView)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addBranchAnnotations()
    }
    
    func addBranchAnnotations() {
        for branch in branches {
            let annotation = MKPointAnnotation()
            annotation.title = branch.name
            annotation.coordinate = branch.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        findNearestBranch(to: userLocation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Разрешено")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Доступ запрещён")
        case .notDetermined:
            print("Статус не определён — запросите разрешение")
        @unknown default:
            print("Неизвестный статус")
        }
    }
    
    func findNearestBranch(to location: CLLocation) {
        var nearestBranch: Branch?
        var shortestDistance = CLLocationDistanceMax

        for branch in branches {
            let branchLocation = CLLocation(latitude: branch.coordinate.latitude, longitude: branch.coordinate.longitude)
            let distance = location.distance(from: branchLocation)
            if distance < shortestDistance {
                shortestDistance = distance
                nearestBranch = branch
            }
        }

        guard let nearest = nearestBranch else { return }

        for annotation in mapView.annotations {
            if let point = annotation as? MKPointAnnotation {
                point.subtitle = nil
            }
        }

        if let nearestAnnotation = mapView.annotations.first(where: { annotation in
            annotation.coordinate.latitude == nearest.coordinate.latitude &&
            annotation.coordinate.longitude == nearest.coordinate.longitude
        }) as? MKPointAnnotation {
            nearestAnnotation.subtitle = "Ближайшее к вам отделение"
            mapView.selectAnnotation(nearestAnnotation, animated: true)
        }
    }
    
    func highlightBranch(_ branch: Branch) {
        for annotation in mapView.annotations {
            if annotation.coordinate.latitude == branch.coordinate.latitude &&
                annotation.coordinate.longitude == branch.coordinate.longitude {
                mapView.selectAnnotation(annotation, animated: true)
                break
            }
        }
    }
}
