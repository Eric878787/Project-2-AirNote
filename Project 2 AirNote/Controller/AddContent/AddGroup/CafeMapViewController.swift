//
//  CafeMapViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/25.
//

import UIKit
import MapKit
import CoreLocation

protocol CafeAddressDelegate {
    func passAddress(_ cafe: Cafe)
}

class CafeMapViewController: BaseViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var cafeMapView: MKMapView!
    @IBOutlet weak var bringToUserLocationButton: UIButton!
    let locationManager = CLLocationManager()
    var cafes: [Cafe] = []
    var delegate: CafeAddressDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCafesInfo()
        navigationItem.title = NavigationItemTitle.recommendedCafe.rawValue
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20.0
        cafeMapView.delegate = self
        configButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringToUserLocationButton.layer.cornerRadius =  bringToUserLocationButton.frame.height / 2
    }
    
}

extension CafeMapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if cafeMapView.userLocation.coordinate.latitude != 0.0 || cafeMapView.userLocation.coordinate.longitude != 0.0 {
            bringToUserLocation()
        } else {
            return
        }
    }
    
    @objc func bringToUserLocation() {
        locationManager.startUpdatingLocation()
        let location = cafeMapView.userLocation
        print(cafeMapView.userLocation.coordinate)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        cafeMapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func fetchCafesInfo() {
        CafeManager.shared.fetchCafeInfo { result in
            
            switch result {
            case .success(let cafes):
                self.cafes = cafes
                self.layoutGroup()
            case .failure(let error):
                self.showBasicConfirmationAlert("????????????", "\(error)")
            }
        }
    }
    
    func configButton() {
        bringToUserLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        bringToUserLocationButton.tintColor = .myDarkGreen
        bringToUserLocationButton.backgroundColor = .white
        bringToUserLocationButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        bringToUserLocationButton.addTarget(self, action: #selector(bringToUserLocation), for: .touchUpInside)
        
    }
    
}

// MARK: Annotation Location
extension CafeMapViewController: MKMapViewDelegate {
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else {
            return nil
        }
        let identifier = "cafe"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.tintColor = .myDarkGreen
            view.rightCalloutAccessoryView = button
        }
        return view
    }
    
    func layoutGroup() {
        for cafe in cafes {
            let coordinate = CLLocationCoordinate2D(latitude: Double(cafe.latitude) ?? 0,
                                                    longitude: Double(cafe.longitude) ?? 0)
            let title = cafe.name
            let subtitle = cafe.address
            let annotation = Annotation(
                coordinate: coordinate,
                title: title,
                subtitle: subtitle,
                groupId: "")
            cafeMapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? Annotation
        let cafe = cafes.filter { $0.name == annotation?.title}
        delegate?.passAddress(cafe[0])
        self.navigationController?.popViewController(animated: true)
    }
    
}
