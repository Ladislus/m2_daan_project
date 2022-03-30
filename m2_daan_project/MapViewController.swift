import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    var _context: NSManagedObjectContext!
    @IBOutlet weak var _map: MKMapView!
    
    let _loc = CLLocationManager()
    var userPosition: CLLocation?
    
    var firstUpdate = true
    
    // Constants to point map on France
    let _long = 2.213749
    let _lat = 46.22
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activate Geoloc'
        self._loc.requestAlwaysAuthorization()
        self._loc.desiredAccuracy = kCLLocationAccuracyBest
        self._loc.requestWhenInUseAuthorization()
        self._loc.startUpdatingLocation()
        self._loc.delegate = self
        self._loc.startUpdatingHeading()
        
        // Set the map on current position or default to France
//        var coords: CLLocationCoordinate2D!
//        if let pos = self.userPosition {
//            print("User current position")
//            coords = CLLocationCoordinate2D(latitude: pos.coordinate.latitude, longitude: pos.coordinate.longitude)
//        } else {
//            print("Default position to France")
//            coords = CLLocationCoordinate2D(latitude: self._lat, longitude: self._long)
//        }
//
//        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
//        let region = MKCoordinateRegion(center: coords, span: span)
//        self._map.setRegion(region, animated: true)
        self._map.delegate = self
        self._map.showsUserLocation = true
        
        // Fetch all chronos
        let chronos = self.getAllChronos()
        for chrono in chronos {
            print("Chrono: \(chrono.name ?? "_"); Lat: \(chrono.lat); Long: \(chrono.lon)")
            // If the chrono is located
            // Long/Lat valid ranges are -180; 180, so default value is set to -1000
            // Ad doubles can't be nullable
            if chrono.lat >= -180 && chrono.lon >= -180 {
                print("Adding Poi")
                // Add the Point of Interest
                self._map.addAnnotation(
                    Poi(title: chrono.name!,
                        coordinate: CLLocationCoordinate2D(latitude: chrono.lat, longitude: chrono.lon),
                        info: chrono.category?.name ?? "_"
                   )
                )
            } else {
                print("Invalid Poi")
            }
        }
    }
    
    // Function called to update the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
             if let pos = locations.last {
                 self.userPosition = pos
                 
                 // The first time the position is updated (when launching the view, but after the viewDidLoad())
                 // Update the position of the map (center the map on ourselves)
                 if self.firstUpdate {
                     self.firstUpdate = false;
                     let coords = CLLocationCoordinate2D(latitude: pos.coordinate.latitude, longitude: pos.coordinate.longitude)
                     let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                     let region = MKCoordinateRegion(center: coords, span: span)
                     self._map.setRegion(region, animated: true)
                 }
             }
         }
    }
    
    private func exitWithMsg(Message msg: String?) {
        if let msg = msg {
            print("[Error] " + msg)
        }
        exit(1)
    }
    
    private func getAllChronos() -> [Chrono] {
        let rqst = Chrono.fetchRequest()
        do {
            return try self._context.fetch(rqst)
        } catch {
            print(error)
            self.exitWithMsg(Message: "Couldn't fetch all Chrono")
            // Unreachable
            return []
        }
    }

    // Function called to display a Poi on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Poi else { return nil }
        let identifier = "Poi"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
    
// Utility class to reprensent pins
class Poi: NSObject, MKAnnotation {
  var title: String?
  var coordinate: CLLocationCoordinate2D
  var info: String
  
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
      self.title = title
      self.coordinate = coordinate
      self.info = info
  }
}
