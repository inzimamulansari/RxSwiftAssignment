//
//  ViewController.swift
//  RxSwiftAssignment
//
//  Created by Apple on 04/03/22.
//

import UIKit
import RxCocoa
import RxSwift

struct countryModel: Codable {
    let code: Int?
    let result: [countryListModel]?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case result
    }
}
struct countryListModel: Codable {
    let code: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case code
        case name
    }
}

public enum RequestType: String {
    case GET, POST, PUT,DELETE
}

class APIRequest {
    let baseURL = URL(string: "https://api.printful.com/countries")!
    var method = RequestType.GET
    var parameters = [String: String]()
    
    
    func request(with baseURL: URL) -> URLRequest {
          var request = URLRequest(url: baseURL)
        request.httpMethod = RequestType.GET.rawValue
           request.addValue("application/json", forHTTPHeaderField: "Accept")
           return request
       }
}



class APICalling {
    // create a method for calling api which is return a Observable
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = apiRequest.request(with: apiRequest.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let model: countryModel = try JSONDecoder().decode(countryModel.self, from: data ?? Data())
                    observer.onNext( model.result as! T)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

class ViewController: UIViewController,UITableViewDelegate {

private let apiCalling = APICalling()
private let disposeBag = DisposeBag()
    
        @IBOutlet var tab:UITableView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
    
            tab.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            let request =  APIRequest()
            let result : Observable<[countryListModel]> = self.apiCalling.send(apiRequest: request)
            _ = result.bind(to: tab.rx.items(cellIdentifier: "cell")) { ( row, model, cell) in
               cell.textLabel?.text = model.name
            }
        }
    
}
