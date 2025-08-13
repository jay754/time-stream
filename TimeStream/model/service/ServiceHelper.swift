//
//  ServiceHelper.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import Foundation
import Alamofire
import UIKit

enum Result<T> {
    case success(_ value: T)
    case error(_ value: Error?)
    
    var value: T? {
        switch self {
        case .error(_):
            return nil
            
        case .success(let value):
            return value
        }
    }
}

typealias ResponseClosure = (_ response: Result<[String: Any]>) -> Void
typealias ProgressClosure = (_ progress: Float) -> Void

class ServiceHelper {
    
    private struct Constants {
//        static let endpoint = "http://localhost:3000/api/v1/"
//        static let endpoint = "http://192.168.100.40:3000/api/v1/"
        
//        static let endpoint = "http://time-production.eu-central-1.elasticbeanstalk.com/api/v1/"
//        static let endpoint = "https://time-stream-prod.herokuapp.com/api/v1/"
        
        // This is the production URL
//        static let endpoint = "https://time-production.herokuapp.com/api/v1/"
        
        static let endpoint = UserDefinedSettings.valueFor(.ENDPOINT)
        
//        static let endpoint = "https://time-stream-prod.herokuapp.com/api/v1/"
//        static let endpoint = "http://192.168.1.7:3000/api/v1/"
    }
    
    private var session = Session.default
    private let firebaseAuthentication = FirebaseAuthentication()
    
    // MARK: Methods
    
    func POST(path: String, data: [String: Any]?, retry: Bool = true, completion: @escaping ResponseClosure) {
        session.request(getEndpoint(path: path), method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers()).responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, retry: retry) {
                self.POST(path: path, data: data, retry: false, completion: completion)
            } completion: { response in
                completion(response)
            }
        })
    }
    
    func DELETE(path: String, data: [String: Any]?, retry: Bool = true, completion: @escaping ResponseClosure) {
        session.request(getEndpoint(path: path), method: .delete, parameters: data, encoding: JSONEncoding.default, headers: headers()).responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, retry: retry) {
                self.DELETE(path: path, data: data, retry: false, completion: completion)
            } completion: { response in
                completion(response)
            }
        })
    }
    
    @discardableResult
    func GET(path: String, data: [String: Any]?, retry: Bool = true, completion: @escaping ResponseClosure) -> DataRequest {
        return session.request(getEndpoint(path: path), method: .get, parameters: data, headers: headers()).responseJSON(completionHandler: { (response) in
            self.handleResponse(response: response, retry: retry) {
                self.GET(path: path, data: data, retry: false, completion: completion)
            } completion: { response in
                completion(response)
            }
        })
    }
    
    func uploadImageToAWS(upload: PresignedUpload, image: UIImage, completion: @escaping VoidClosure) {
        let imgData = image.jpegData(compressionQuality: 1.0)!

        session.upload(imgData, to: upload.url.absoluteURL, method: .put, requestModifier: {$0.timeoutInterval = 3600 }).response { (response) in
            if response.error == nil {
                completion(.success(()))
            } else {
                completion(.error(nil))
            }
        }
    }
    
    func uploadVideoToAWS(upload: PresignedUpload, video: URL, progress: ProgressClosure?, completion: @escaping VoidClosure) {
        do {
            let data = try Data(contentsOf: video)
            session.upload(data, to: upload.url.absoluteURL, method: .put, requestModifier: {$0.timeoutInterval = 3600 }).uploadProgress(closure: { value in
                
                // Report back the progress
                progress?(Float(value.fractionCompleted))
            }).response { (response) in
                if response.error == nil {
                    completion(.success(()))
                } else {
                    completion(.error(response.error))
                }
            }
        } catch {
            completion(.error(nil))
        }
    }
    
    
    func multipartFormUpload(path: String, video: URL?, thumbnail: UIImage?, params: [String: Any], progress: ProgressClosure?, completion: @escaping ResponseClosure) {
        do {
            let thumbnailData = thumbnail?.jpegData(compressionQuality: 0.5)
            
            session.upload(multipartFormData: { multipartFormData in
                if let clip = video {
                    multipartFormData.append(clip, withName: "clip", fileName: "clip", mimeType: "video")
                }
                
                if let thumbnail = thumbnailData {
                    multipartFormData.append(thumbnail, withName: "thumbnail", fileName: "thumbnail", mimeType: "image")
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: params) {
                    multipartFormData.append(data, withName: "data")
                }
                
            }, to: getEndpoint(path: path), headers: headers()).uploadProgress(closure: { value in
                // Report back the progress
                progress?(Float(value.fractionCompleted))
            }).responseJSON(completionHandler: { (response) in                
                self.handleResponse(response: response, retry: false, refreshClosure: nil, completion: completion)
            })
        } catch {
            completion(.error(nil))
        }
    }
    
    
    func multipartFormUpload(path: String, photo: UIImage?, params: [String: Any], progress: ProgressClosure?, completion: @escaping ResponseClosure) {
        do {
            let photoData = photo?.jpegData(compressionQuality: 0.5)
            
            session.upload(multipartFormData: { multipartFormData in
                
                if let photoData = photoData {
                    multipartFormData.append(photoData, withName: "photo", fileName: "photo", mimeType: "image")
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: params) {
                    multipartFormData.append(data, withName: "data")
                }
                
            }, to: getEndpoint(path: path), headers: headers()).uploadProgress(closure: { value in
                // Report back the progress
                progress?(Float(value.fractionCompleted))
            }).responseJSON(completionHandler: { (response) in
                self.handleResponse(response: response, retry: false, refreshClosure: nil, completion: completion)
            })
        } catch {
            completion(.error(nil))
        }
    }
    
    // MARK: Private methods
    
    private func handleResponse(response: AFDataResponse<Any>, retry: Bool, refreshClosure: EmptyClosure?, completion: @escaping ResponseClosure) {
        let statusCode = response.response?.statusCode
        if statusCode == 401 {
           // The authorization token has expired, refresh it if needed
            if retry {
                self.refreshToken {
                    refreshClosure?()
                }
            } else {
                completion(.error(nil))
            }
            
            return
        }
        
        if let error = response.error,
           error.responseCode == AFError.explicitlyCancelled.responseCode {
            // The request was canceled, do nothing
            return
        }
        
        if statusCode != 200 {
            completion(.error(nil))
            return
        }
        
        switch response.result {
        case .success(let data):
            if let dict = data as? [String: Any] {
                completion(.success(dict))
                
                return
            }
            
            fallthrough
        case .failure(_):
            completion(.error(NSError.invalidResponse))
        }
    }
    
    private func refreshToken(completion: @escaping EmptyClosure) {
        firebaseAuthentication.refreshAccessToken { (result) in
            if case let .success(code) = result {
                Context.current.accessToken = code
            }
            
            completion()
        }
    }
    
    private func getEndpoint(path: String) -> String {
        let urlComps = URLComponents(string: Constants.endpoint + path)!
        let result = urlComps.url!
        
        return result.absoluteString
    }
    
    private func headers() -> HTTPHeaders?  {
        var headers = HTTPHeaders()
        headers.add(HTTPHeader(name: "Content-Type", value: "application/json"))
        headers.add(HTTPHeader(name: "Authorization", value: Context.current.accessToken ?? ""))
        
        return headers
    }
    
}
