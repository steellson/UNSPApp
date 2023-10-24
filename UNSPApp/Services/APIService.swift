//
//  APIService.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - Protocol

protocol APIServiceProtocol: AnyObject {
    func fetchPhotos(completion: @escaping (Result<[Photo], RequestError>) -> Void)
    func downloadPhoto(fromURL url: String, completion: @escaping (Result<Data, RequestError>) -> Void)
}

//MARK: - Selections

enum APIEndpoints: String {
    case getPhotos = "/photos"
}

enum HTTPMethod: String {
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
    
}

extension APIService: APIServiceProtocol {
    
    //MARK:  Get all photos
    func fetchPhotos(completion: @escaping (Result<[Photo], RequestError>) -> Void) {
        guard let combinedURL = URL(
            string: baseUrlString + endpoint + "?client_id=\(client.clientID)"
        ) else {
            print("ERROR: Coudlt combine URL")
            completion(.failure(.urlError))
            return
        }
        
        var request = URLRequest(url: combinedURL)
        request.httpMethod = "GET"
        
        urlSession.dataTask(with: request) { data, response, error in
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
                let photoResponseData = try self.jsonDecoder.decode(GetPhotosResponse.self, from: data)
                let photos = photoResponseData.map {
                    Photo(
                        id: $0.id,
                        links: $0.links
                    )
                }
                completion(.success(photos))
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
