//
//  APIService.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - Protocol

protocol APIServiceProtocol: AnyObject {
    func fetchPhotos(withParameters                     // construct generic
                     parameters: Query,
                     completion: @escaping (Result<[Photo], RequestError>) -> Void)
    
    func fetchRandomPhotos(withParameters               // construct generic
                           parameters: Query,
                           completion: @escaping (Result<[Photo], RequestError>) -> Void)
    
    func downloadPhoto(fromURL
                       url: String,
                       completion: @escaping (Result<Data, RequestError>) -> Void)
    
    func searchPhoto(withText
                     text: String,
                     itemsPerPage: Int,
                     completion: @escaping (Result<[Photo], RequestError>) -> Void)
}

//MARK: - Selections

enum HTTPMethod: String {
    case GET
    case POST
}

enum RequestError: Error {
    case urlError
    case decodingError
    case requestError
    case noData
    case searchError
}


//MARK: - Impl

final class APIService {
    
    private let client = Client(clientID: R.Strings.apiAccessKey.rawValue)
    
    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private let jsonDecoder = JSONDecoder()
}

extension APIService: APIServiceProtocol {
    
    //MARK:  Get all photos
    func fetchPhotos(withParameters
                     parameters: Query,
                     completion: @escaping (Result<[Photo], RequestError>) -> Void) {
                
        guard let url = URLBuilder.buildURL(
            with: .https,
            host: .main,
            path: .getPhotos,
            queryItems: [
                .init(
                    name: Query.ArgumentName.page.rawValue,
                    value: "\(parameters.currentPage)"
                ),
                .init(
                    name: Query.ArgumentName.per_page.rawValue,
                    value: "\(parameters.perPage)"
                )
            ]
        ) else {
            print("ERROR: Couldnt build URL"); return
        }
  
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = [
            "Accept": "v1",
            "Authorization": "Client-ID \(client.clientID)"
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
                print(R.Strings.photosFetched.rawValue)
            } catch {
                completion(.failure(.decodingError))
                print("ERROR: Decoding images promlem \(error)")
            }
        }.resume()
        
        print("REQUEST: \(request.debugDescription)")
    }
    
    //MARK:  Get random photos
    func fetchRandomPhotos(withParameters
                           parameters: Query,
                           completion: @escaping (Result<[Photo], RequestError>) -> Void) {
                
        guard let url = URLBuilder.buildURL(
            with: .https,
            host: .main,
            path: .getRandomPhotos,
            queryItems: [
                .init(
                    name: Query.ArgumentName.count.rawValue,
                    value: "\(parameters.count)"
                )
            ]
        ) else {
            print("ERROR: Couldnt build URL"); return
        }
  
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = [
            "Accept": "v1",
            "Authorization": "Client-ID \(client.clientID)"
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
                print(R.Strings.photosFetched.rawValue)
            } catch {
                completion(.failure(.decodingError))
                print("ERROR: Decoding images promlem \(error)")
            }
        }.resume()
        
        print("REQUEST: \(request.debugDescription)")
    }
    
    
    //MARK: Get concrete photo
    func downloadPhoto(fromURL
                       url: String,
                       completion: @escaping (Result<Data, RequestError>) -> Void) {
        
        guard let url = URL(string: url) else {
            print("ERROR: Failed recieved URL"); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Accept" : "v1",
            "Authorization": "Client-ID \(client.clientID)"
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
        
        print("REQUEST: \(request.debugDescription)")
    }
    
    //MARK: Search with text
    func searchPhoto(withText
                     text: String,
                     itemsPerPage: Int,
                     completion: @escaping (Result<[Photo], RequestError>) -> Void) {
        
        guard let url = URLBuilder.buildURL(
            with: .https,
            host: .main,
            path: .getPhotos,
            queryItems: [
                .init(
                    name: Query.ArgumentName.per_page.rawValue,
                    value: String(itemsPerPage)
                     ),
                .init(
                    name: Query.ArgumentName.query.rawValue,
                    value: text
                )
            ]
        ) else {
            print("ERROR: Couldnt build URL"); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Accept" : "v1",
            "Authorization": "Client-ID \(client.clientID)"
        ]

        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else {
                print("ERROR: Search failed \(String(describing: error))")
                completion(.failure(.searchError))
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
            } catch {
                completion(.failure(.decodingError))
                print("ERROR: Decoding images promlem \(error)")
            }
            
        }.resume()
        
        print("REQUEST: \(request.debugDescription)")
    }
}
