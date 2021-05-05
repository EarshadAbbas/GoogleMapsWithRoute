
import UIKit

import GoogleMaps
import GooglePlaces
import CoreLocation
import SwiftyJSON

class ResturantListViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var currentArea: UILabel!
    
    
    var selectedIndex = -1
    var isCollapse = false
    var currentLocation: CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    var resturantList = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        tableview.delegate = self
        tableview.dataSource = self
        self.tableview.estimatedRowHeight = 50.0
        self.tableview.rowHeight = UITableView.automaticDimension
        locationManager.requestWhenInUseAuthorization()
        self.getNearestPlace()
       
    }
    
    
    func getNearestPlace()
    {
        
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            self.currentLocation = locationManager.location?.coordinate ?? nil
            
            self.getPlace(for: locationManager.location!) { (place) in
                print("Place ",place?.name)
                self.currentArea.text = "\(place?.name ?? ""), \(place?.locality ?? "")"
            }
        }
        let URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.currentLocation.latitude),\(self.currentLocation.longitude)&radius=3000&type=restaurant&keyword=cruise&key=AIzaSyDYMPVy4xArN4D1UWN-k3mdN2c1AUta6vI"
        APIManager.sharedInstance.getJsonResponse(withEndPoint: URL) { (resp, isSuccess, err) in
            print("Nearby resp :",resp ?? "", "\n\n IsSuccess ", isSuccess)
            if(isSuccess)
            {
                do{
                    let jsondata = try JSON(data: resp as! Data)
                    print("Nearby resp :",jsondata["results"].arrayValue)
                    self.resturantList = jsondata["results"].arrayValue
                    self.tableview.reloadData()
                    
                }
                catch
                {
                   
                }
            }
            else
            {
                
            }
        }
    }
    
    func getPlace(for location: CLLocation,
                      completion: @escaping (CLPlacemark?) -> Void) {
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                
                guard error == nil else {
                    print("*** Error in \(#function): \(error!.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?[0] else {
                    print("*** Error in \(#function): placemark is nil")
                    completion(nil)
                    return
                }
                
                completion(placemark)
            }
        }
    


}


extension ResturantListViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resturantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
        let data = self.resturantList[indexPath.row] as! JSON
//        print("NAME : ",data["name"].string)
        cell.configureCell(name: data["name"].string ?? "", address: data["vicinity"].string ?? "", icon: data["icon"].string ?? "", status: data["business_status"].string ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(self.selectedIndex == indexPath.row && self.isCollapse == true)
        {
        return 150.0
        }
        else {
            return 75.0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == indexPath.row
        {
            self.isCollapse = !self.isCollapse
        }
        else
        {
            self.isCollapse = true
        }
        
        self.selectedIndex = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
