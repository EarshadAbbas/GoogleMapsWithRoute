import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import SwiftyJSON

class ViewController: UIViewController {
    var resultsViewController: GMSAutocompleteResultsViewController?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var destinationLocation:CLLocationCoordinate2D!

    var region:CLCircularRegion!
    @IBOutlet var mapView: GMSMapView!
    
    
    var searchController: UISearchController?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        
        self.enableLocation()
        self.addAutoCompleteSearchBar()
        
        
        
        
    }
    
    func enableLocation()
    {
        self.mapView.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            self.currentLocation = locationManager.location?.coordinate ?? nil
        }
    }
    
    func addAutoCompleteSearchBar()
    {
        
        resultsViewController = GMSAutocompleteResultsViewController()
            resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
            searchController?.searchResultsUpdater = resultsViewController

        let subView = UIView(frame: CGRect(x: 0, y: 85.0, width: 350.0, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

       
        definesPresentationContext = true
    }
    
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last
        
        

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animate(to: camera)

//        self.locationManager.stopUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region")
        self.showAlert(message: "You have reached near the destination")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit region")
        self.showAlert(message: "You are leaving from your destination")
    }

}


extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    self.destinationLocation = place.coordinate
    self.mapView.clear()
    self.drawRoute()
    self.addMarker(place: place)
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    
    print("Error: ", error.localizedDescription)
  }

    
    func drawRoute()
    {
        
        let sourceLocation = "\(self.currentLocation.latitude),\(self.currentLocation.longitude)"
        let destinationLocation = "\(self.destinationLocation.latitude),\(self.destinationLocation.longitude)"
        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyDYMPVy4xArN4D1UWN-k3mdN2c1AUta6vI"
        APIManager.sharedInstance.getJsonResponse(withEndPoint: URL) { (resp, isSuccess, err) in
            
            
            if(isSuccess)
            {
                do{
                    let jsondata = try JSON(data: resp as! Data)
                    let routes = jsondata["routes"].arrayValue
                     print("\n\nRoutes :",routes)
                    for route in routes {
                        let overview_polyline = route["overview_polyline"].dictionary
                        let points = overview_polyline?["points"]?.string
                        let path = GMSPath.init(fromEncodedPath: points ?? "")
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeColor = .systemBlue
                        polyline.strokeWidth = 5
                        polyline.map = self.mapView
                    }
                    
                    let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude), zoom: 12)
                    self.mapView.animate(to: camera)
                }
                catch
                {
                   
                }
            }
            
            
        }
    }
    
    
    func addMarker(place: GMSPlace)
    {
        
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: self.destinationLocation.latitude, longitude: self.destinationLocation.longitude)
        destinationMarker.title = place.name
        destinationMarker.snippet = place.description
        destinationMarker.map = self.mapView
        
        self.region = CLCircularRegion(
            center: place.coordinate,
            radius: 100,
            identifier: "")
        
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
        
        self.locationManager.startMonitoring(for: self.region)
        
        
    }
    
    
    func showAlert(message : String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
           
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


