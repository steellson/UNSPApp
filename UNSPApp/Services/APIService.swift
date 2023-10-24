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
}

//MARK: - Selections

enum HTTPMethod: String {
    case GET
    case POST
}


enum RequestError: Error {
    case combineUrlError
    case decodingError
}

enum APIEndpoints: String {
    case getPhotos = "/photos"
}


//MARK: - Impl

final class APIService {
    
    private let baseUrlString: String = R.Strings.baseUrlString.rawValue
    private let endpoint = APIEndpoints.getPhotos.rawValue

    private let client = Client(clientID: R.Strings.apiAccessKey.rawValue)
    
    private let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private let jsonDecoder = JSONDecoder()

}

//MARK: - Protocol extension

extension APIService: APIServiceProtocol {
    
    func fetchPhotos(completion: @escaping (Result<[Photo], RequestError>) -> Void) {
        guard let combinedURL = URL(
            string: baseUrlString + endpoint + "?client_id=\(client.clientID)"
        ) else {
            print("ERROR: Coudlt combine URL")
            completion(.failure(.combineUrlError))
            return
        }

        var request = URLRequest(url: combinedURL)
        request.httpMethod = "GET"

        urlSession.dataTask(with: request) { data, response, error in
            do {
                let photoResponseData = try self.jsonDecoder.decode(GetPhotosResponse.self, from: data!)
                let photos = photoResponseData.map {
                    Photo(
                        id: $0.id,
                        links: $0.links
                    )
                }
                completion(.success(photos))
                print("SUCCESS: Photos fetched succsessfully!")
            } catch {
                completion(.failure(.decodingError))
                print("ERROR: Decoding images promlem \(error)")
            }
        }.resume()
    }
}
