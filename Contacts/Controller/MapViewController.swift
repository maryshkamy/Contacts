//
//  MapViewController.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 05/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var delegate: AddressProtocol?

    @IBOutlet weak var mapKitView: MKMapView! {
        didSet {
            mapKitView.delegate = self

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
            mapKitView.addGestureRecognizer(longPress)
        }
    }

    private var locationManager = CLLocationManager()

    @objc private func addPin(_ sender: UILongPressGestureRecognizer) {
        let annotations = mapKitView.annotations.filter { (annotation) -> Bool in
            return annotation.isKind(of: MKPointAnnotation.self)
        }

        mapKitView.removeAnnotations(annotations)

        let touchPoint = sender.location(in: mapKitView)
        let coordinate = mapKitView.convert(touchPoint, toCoordinateFrom: mapKitView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "I'm here"
        annotation.subtitle = "Right here"

        mapKitView.addAnnotation(annotation)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
            view.isDraggable = true

            lookUpCurrentLocation(location: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude),
                                  completionHandler: { placemark in
                                    self.delegate?.didReceive(placemark: placemark)
            })

            return view
        }

        return nil
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if let location = locations.last {
            let camera = MKMapCamera(lookingAtCenter: location.coordinate, fromDistance: 1500, pitch: 0, heading: 0)

            mapKitView.setCamera(camera, animated: true)
            mapKitView.showsUserLocation = true
        }
    }

    func lookUpCurrentLocation(location: CLLocation?, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        if let lastLocation = location {
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                } else {
                    completionHandler(nil)
                }
            })
        } else {
            completionHandler(nil)
        }
    }
}
