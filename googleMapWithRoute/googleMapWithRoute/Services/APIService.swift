
import Foundation
import SwiftyJSON
import Alamofire


class APIManager {
    public func hasInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
        
    }
    
    public static let sharedInstance : APIManager = {
        let instance = APIManager()
        return instance
    }()
    
    typealias CompletionHandler = (Any?, Bool, Error?) -> ()
    
    public func getJsonResponse(withEndPoint url:String, withHeaders headers:HTTPHeaders? = nil, completion:@escaping CompletionHandler) {
        
        if !hasInternet() {
            return
        }
        
//        //print("\n\n(GET) API-->")
        AF.request( url, method: .get, encoding: URLEncoding.default, headers: headers){ $0.timeoutInterval = 700 }.response { (serverResponse) in
            guard let statusCode = serverResponse.response?.statusCode else {
                completion(nil, false, nil)
                return
            }
            
            switch statusCode{
            case 200...299:
                completion(serverResponse.data, true, nil)
//                //print("case 200")
                break
                
            case 401:
                if let errorInfoData = serverResponse.data{
                    //print(String(data: errorInfoData, encoding: .utf8) ?? "401 -Empty Response")
                }
                //print("case 401")
                
                break
                
            case 400...599:
                if let errorInfoData = serverResponse.data {
                    //print(String(data: errorInfoData, encoding: .utf8) ?? "400 -Empty Response")
                }
                completion(serverResponse.data, false, serverResponse.error)
                //print("case 400")
                break
                
            default:
                break
            }
        }
    }
    
    
}
