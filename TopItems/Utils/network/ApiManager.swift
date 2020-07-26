//
//  ApiManager.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import RxSwift
import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class ApiManager: NSObject {
    
    //MARK: - Properties
    let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    let versionName = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    let iOSVersion = UIDevice.current.systemVersion
    let iOSVersionCode = ProcessInfo().operatingSystemVersion.majorVersion
    let deviceType = UIDevice.current.model
    let deviceId = UIDevice.current.identifierForVendor?.description
    static var sharedApiManager: ApiManager!
    
    static var baseURL: URL!
    
    private var imageCache: NSCache<NSString, AnyObject>! = NSCache()
    
    private var sessionManager: SessionManager
    private var disposeBag = DisposeBag()
    
    //MARK: - Methods
    
    //MARK: Public
    
    init(baseUrl: String) {
        ApiManager.baseURL =  URL(string: baseUrl)!
        
        // get the default headers
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        // add your custom header
        headers["User-Agent"] = "App \(versionName)/\(buildNumber) (iOS \(iOSVersion)/\(iOSVersionCode); \(deviceType)/\(deviceId ?? ""))"

        // create a custom session configuration
        let configuration = URLSessionConfiguration.default
        // add the headers
        configuration.httpAdditionalHeaders = headers
      
        // create a session manager with the configuration
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        super.init()
        
        ApiManager.sharedApiManager = self
    }
    
    /**
     Main handler of all the requests
     
     - Parameter url: a type conforming to `URLRequestConvertible`.
     - Parameter authenticate: boolean that identifies if the `URLRequest` needs an access token.
     - Parameter completion: a callback that contains and an optional `JSON` or an optional `NSError`, depending if the the requests succeeded or not.
     
     - Returns: an instance of the `URLRequest` created with the supplied parameters.
     */
    @discardableResult
    func perform(request: Request) -> Observable<JSON> {
        return Observable.create({ observer -> Disposable in
            
            let urlRequest = request.getRequest()
            self.sessionManager.request(urlRequest).responseJSON(completionHandler: { response in
                if let error = response.error {
                    print(urlRequest)
                    print(response.response as Any)
                    print("request body: \(String(describing: request.parameters))")
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    observer.onError(APIClientError.RequestError(error))
                } else {
                    guard let httpResponse = response.response else {
                        observer.onError(APIClientError.CouldNotDecodeJSON)
                        return
                    }
                    
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        if httpResponse.statusCode == 204 {
                            observer.onCompleted()
                        }
                        
                        do {
                            let json = try JSON(data: response.data ?? Data(),
                                                options: JSONSerialization.ReadingOptions.allowFragments)
                            
                            print(urlRequest)
                            print("request body: \(String(describing: request.parameters))")
                            print(response.response as Any)
                            print(json)
                            observer.onNext(json)
                            observer.onCompleted()
                        } catch {
                            observer.onError(APIClientError.CouldNotDecodeJSON)
                        }
                    } else {
                        var apiError: ApiError!
                        if let responseData = response.data {
                            if let json = try? JSON(data: responseData,
                                                    options: JSONSerialization.ReadingOptions.allowFragments) {
                                if let apiResponse = ApiResponse(json: json),
                                    let errors = apiResponse.errors,
                                    errors.message != "" {
                                    apiError = errors
                                }
                                print(urlRequest)
                                print("request body: \(String(describing: request.parameters))")
                                print(response.response as Any)
                                print(json)
                            }
                        }
                        
                        if let apiError = apiError {
                            observer.onError(self.getBadStatus(code: httpResponse.statusCode,
                            apiError: apiError))
                            print(apiError)
                        }
                    }
                }
            })
            return Disposables.create()
        })
    }
    
    func performWithImageReponse(request: Request, isDirectory: Bool? = true) -> Observable<Image> {
        return Observable.create({ observer -> Disposable in
            
            let urlRequest = request.getRequest(isDirectory: isDirectory)
            self.sessionManager.request(urlRequest).responseImage(completionHandler: { response in
                if let error = response.error {
                    print(urlRequest)
                    print(response.response as Any)
                    observer.onError(APIClientError.RequestError(error))
                } else {
                    guard let httpResponse = response.response else {
                        observer.onError(APIClientError.CouldNotRetrieveImage)
                        return
                    }
                    
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        print(urlRequest)
                        print(response.response as Any)
                        
                        guard response.result.value != nil else {
                            observer.onError(APIClientError.CouldNotRetrieveImage)
                            return
                        }
                        observer.onNext(response.result.value!)
                        observer.onCompleted()
                    } else {
                        print(urlRequest)
                        print(response.response as Any)
                        observer.onError(self.getBadStatus(code: httpResponse.statusCode,
                                                           apiError: response.error as! ApiError))
                    }
                }
            })
            return Disposables.create()
        })
    }
    
    func performWithoutBaseUrlWithImageReponse(request: Request, cgsize: CGSize? = nil) -> Observable<Image> {
        return Observable.create({ observer -> Disposable in
            
            //check cache first
            let imageCacheKey = request.path as NSString
            if let image = self.imageCache.object(forKey: imageCacheKey) as? Image {
                observer.onNext(image)
                observer.onCompleted()
                return Disposables.create()
            }
            
            //proceed to download
            var urlRequest = URLRequest(url: URL(string: request.path)!)
            urlRequest.httpMethod = request.method.rawValue
            
            self.sessionManager.request(urlRequest).responseImage(completionHandler: { response in
                if let error = response.error {
                    print(urlRequest)
                    print(response.response as Any)
                    observer.onError(APIClientError.RequestError(error))
                } else {
                    guard let httpResponse = response.response else {
                        observer.onError(APIClientError.CouldNotRetrieveImage)
                        return
                    }
                    
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        print(urlRequest)
                        print(response.response as Any)
                        
                        guard response.result.value != nil else {
                            observer.onError(APIClientError.CouldNotRetrieveImage)
                            return
                        }
                        
                        //save to cache first
//                        if let size = cgsize, let image = response.result.value!.resize(targetSize: size) {
//                            self.imageCache.setObject(image, forKey: imageCacheKey)
//                        } else {
                            self.imageCache.setObject(response.result.value!, forKey: imageCacheKey)
//                        }
                        
                        observer.onNext(response.result.value!)
                        observer.onCompleted()
                    } else {
                        print(urlRequest)
                        print(response.response as Any)
                        observer.onError(self.getBadStatus(code: httpResponse.statusCode,
                                                           apiError: response.error as! ApiError))
                    }
                }
            })
            return Disposables.create()
        })
    }

    func performWithHttpStatus(request: Request) -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            
            let urlRequest = request.getRequest()
            self.sessionManager.request(urlRequest).responseJSON(completionHandler: { response in
                if let error = response.error {
                    print(urlRequest)
                    print(response.response as Any)
                    print("request body: \(String(describing: request.parameters))")
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    observer.onError(APIClientError.RequestError(error))
                } else {
                    print(urlRequest)
                    print(response.response as Any)
                    print("request body: \(String(describing: request.parameters))")
                    
                    guard let httpResponse = response.response else {
                        observer.onError(APIClientError.CouldNotDecodeJSON)
                        return
                    }
                    
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        var apiError: ApiError!
                        if let responseData = response.data {
                            if let json = try? JSON(data: responseData,
                                                    options: JSONSerialization.ReadingOptions.allowFragments) {
                                if let apiResponse = ApiResponse(json: json),
                                    let errors = apiResponse.errors,
                                    errors.message != "" {
                                    apiError = errors
                                }
                                print(urlRequest)
                                print(response.response as Any)
                                print(json)
                            }
                        }
                        
                        if let apiError = apiError {
                            observer.onError(self.getBadStatus(code: httpResponse.statusCode,
                            apiError: apiError))
                            print(apiError)
                        }
                    }
                }
            })
            return Disposables.create()
        })
    }
    
    func getUrl() -> URL {
        return ApiManager.baseURL
    }
    
    //MARK: Private
    
    private func getBadStatus(code: Int, apiError: ApiError) -> APIClientError {
        switch code {
        case 401:
            return .Unauthorized(apiError)
        case 403:
            return .Forbidden(apiError)
        case 503:
            return .ServiceUnavailable(apiError)
        default:
            return .ApiError(apiError)
        }
    }
}
