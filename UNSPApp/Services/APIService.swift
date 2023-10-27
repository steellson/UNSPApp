//
//  APIService.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - Protocol

protocol APIServiceProtocol: AnyObject {
    var perPage: Int { get set }
    var currentPage: Int { get set }
    
    func fetchPhotos(completion: @escaping (Result<[Photo], RequestError>) -> Void)
    func downloadPhoto(fromURL url: String, completion: @escaping (Result<Data, RequestError>) -> Void)
}

//MARK: - Selections

enum APIEndpoints: String {
    case getPhotos = "/photos"
}

enum HTTPMethod {
    case GET
    case POST
}

enum RequestError: Error {
    case urlError
    case decodingError
    case requestError
    case noData
}


//MARK: - Impl

final class APIService {
    
    private let baseUrlString: String = R.Strings.baseUrlString.rawValue
    private let endpoint = APIEndpoints.getPhotos.rawValue
    
    private let client = Client(clientID: R.Strings.apiAccessKey.rawValue)
    
    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private let jsonDecoder = JSONDecoder()
    
    var perPage: Int = 30
    var currentPage: Int = 1
}

extension APIService: APIServiceProtocol {
    
    //MARK:  Get all photos
    func fetchPhotos(completion: @escaping (Result<[Photo], RequestError>) -> Void) {
        
        let clientIdParameter = "?client_id=\(client.clientID)"
        let perPageParameter = "&per_page=\(perPage)"
        let currentPageParameter = "&page=\(currentPage)"
        
        guard let combinedURL = URL(
            string: baseUrlString + endpoint + clientIdParameter + perPageParameter + currentPageParameter
        ) else {
            print("ERROR: Coudlt combine URL")
            completion(.failure(.urlError))
            return
        }
        
        var request = URLRequest(url: combinedURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Accept": "v1"
        ]
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else {
                print("ERROR: Request error \(String(describing: error))")
                completion(.failure(.requestError))
                return
            }
            
            guard let data = data else {
                print("ERROR: Couldnt get data \(String(describing: error))")
                completion(.failure(.noData))
                return
            }
            
            do {
                guard let photoResponseData = try self?.jsonDecoder.decode(GetPhotosResponse.self, from: data) else {
                    print("ERROR: Couldnt decode photoResponseData"); return
                }
                let photos = photoResponseData.map {
                    Photo(
                        id: $0.id,
                        width: $0.width,
                        height: $0.height,
                        urls: $0.urls,
                        links: $0.links
                    )
                }
                completion(.success(photos))
                self?.currentPage += 1
                print(R.Strings.photosFetched.rawValue)
            } catch {
                completion(.failure(.decodingError))
                print("ERROR: Decoding images promlem \(error)")
            }
        }.resume()
    }
    
    
    //MARK: Get concrete photo
    func downloadPhoto(fromURL url: String, completion: @escaping (Result<Data, RequestError>) -> Void) {
        guard let currentURL = URL(string: url) else {
            print("ERROR: Coudlt get URL")
            completion(.failure(.urlError))
            return
        }
        
        var request = URLRequest(url: currentURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Accept" : "v1"
        ]
        
        urlSession.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("ERROR: Download photo request error \(String(describing: error))")
                completion(.failure(.requestError))
                return
            }
            
            guard let data = data else {
                print("ERROR: Couldnt get data \(String(describing: error))")
                completion(.failure(.noData))
                return
            }
            completion(.success(data))
            print(R.Strings.photoFetched.rawValue)

        }.resume()
    }
}
