//
//  NetworkService.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 19/10/25.
//

import Foundation

protocol NetworkServiceProtocol: AnyObject {
    @discardableResult
    func request<T: JSONDecodable>(
        urlString: String,
        method: HTTPMethod,
        parameters: JSONObject,
        headers: [String: String],
        body: JSONEncodable?,
        completion: @escaping (Result<T, NetworkServiceError>) -> Void
    ) -> URLSessionDataTask?
    
    func request<T: JSONDecodable>(
        urlString: String,
        method: HTTPMethod,
        parameters: JSONObject,
        headers: [String: String],
        body: JSONEncodable?
    ) async throws -> T
    
    @discardableResult
    func upload<T: JSONDecodable>(
        urlString: String,
        fileData: Data,
        fileName: String,
        fieldName: String,
        mimeType: String,
        parameters: [String: String],
        headers: [String: String],
        completion: @escaping (Result<T, NetworkServiceError>) -> Void
    ) -> URLSessionUploadTask?
    
    func upload<T: JSONDecodable>(
        urlString: String,
        fileData: Data,
        fileName: String,
        fieldName: String,
        mimeType: String,
        parameters: [String: String],
        headers: [String: String]
    ) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    static let shared: NetworkService = NetworkService()
    
    private init() { }
    
    @discardableResult
    func request<T: JSONDecodable>(
        urlString: String,
        method: HTTPMethod = .get,
        parameters: JSONObject = [:],
        headers: [String: String] = [:],
        body: JSONEncodable? = nil,
        completion: @escaping (Result<T, NetworkServiceError>) -> Void
    ) -> URLSessionDataTask? {
        guard urlString.hasPrefix(APIConfig.baseURL) else {
            completion(.failure(.invalidURL))
            return nil
        }
        
        guard var components = URLComponents(string: urlString) else {
            completion(.failure(.invalidURL))
            return nil
        }
        
        if !parameters.isEmpty {
            var queryItems: [URLQueryItem] = []
            
            for (key, value) in parameters {
                if let arrayValue = value as? [Any] {
                    // If the value is an array, loop over it and add each item separately
                    for item in arrayValue {
                        queryItems.append(URLQueryItem(name: key, value: String(describing: item)))
                    }
                } else {
                    // Otherwise, just add the single key/value
                    queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
                }
            }
            
            components.queryItems = queryItems
        }
        
        guard let finalURL = components.url else {
            completion(.failure(.invalidURL))
            return nil
        }
            
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "true")
        
        if let body: JSONObject = body?.toDictionary() {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completeOnMain(.failure(.bodyParsingFailed), completion)
                return nil
            }
        }

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            NetworkLogger.logResponse(data: data, response: response, error: error)
            
            if let error: Error = error {
                let nsError: NSError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet {
                    completeOnMain(.failure(.noInternetConnection), completion)
                    return
                }
//                assertionFailure("Request Failed")
                completeOnMain(.failure(.requestFailed(error)), completion)
                return
            }

            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                assertionFailure("invalid Response")
                completeOnMain(.failure(.invalidResponse), completion)
                return
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                completeOnMain(.failure(.statusCode(httpResponse.statusCode)), completion)
                return
            }

            // Decode response
            guard let data: Data = data else {
                completeOnMain(.failure(.invalidResponse), completion)
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                if let arrayType = T.self as? JSONArrayProtocol.Type,
                   let jsonArray = jsonObject as? [JSONObject] {
                    do {
                        let typedArray = try arrayType.init(jsonArray: jsonArray)
                        guard let casted = typedArray as? T else {
                            let castError = NSError(
                                domain: "TypeCasting",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Failed to cast \(type(of: typedArray)) to \(T.self)"
                                ]
                            )
                            completeOnMain(.failure(.decodingFailed(castError)), completion)
                            return
                        }
                        completeOnMain(.success(casted), completion)
                    } catch {
                        completeOnMain(.failure(.decodingFailed(error)), completion)
                    }
                    return
                }

                if let jsonDict: JSONObject = jsonObject as? JSONObject {
                    let decoded = try T(json: jsonDict)
                    completeOnMain(.success(decoded), completion)
                    return
                }
            } catch {
//                assertionFailure("Decoding has Failed with Error: \(error)")
                completeOnMain(.failure(.decodingFailed(error)), completion)
            }
        }
        
        task.resume()
        return task
    }
    
    func request<T: JSONDecodable>(
        urlString: String,
        method: HTTPMethod,
        parameters: JSONObject,
        headers: [String: String],
        body: JSONEncodable?
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            request(
                urlString: urlString,
                method: method,
                parameters: parameters,
                headers: headers,
                body: body
            ) { ( result: Result<T, NetworkServiceError>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    @discardableResult
    func upload<T: JSONDecodable>(
        urlString: String,
        fileData: Data,
        fileName: String,
        fieldName: String = "file",
        mimeType: String = "application/octet-stream",
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        completion: @escaping (Result<T, NetworkServiceError>) -> Void
    ) -> URLSessionUploadTask? {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "true")
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(fileData: fileData, fileName: fileName, fieldName: fieldName, mimeType: mimeType, parameters: parameters, boundary: boundary)

        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            NetworkLogger.logResponse(data: data, response: response, error: error)
            
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let dict = json as? JSONObject {
                    let decoded = try T(json: dict)
                    completion(.success(decoded))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        
        task.resume()
        return task
    }
    
    func upload<T>(urlString: String, fileData: Data, fileName: String, fieldName: String, mimeType: String, parameters: [String : String], headers: [String : String]) async throws -> T where T : JSONDecodable {
        
        try await withCheckedThrowingContinuation { continuation in
            upload(
                urlString: urlString,
                fileData: fileData,
                fileName: fileName,
                fieldName: fieldName,
                mimeType: mimeType,
                parameters: parameters,
                headers: headers
            ) { ( result: Result<T, NetworkServiceError>) in
                switch result {
                case .success(let decoded):
                    continuation.resume(returning: decoded)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private extension NetworkService {
    func completeOnMain<T>(_ result: Result<T, NetworkServiceError>, _ completion: @escaping (Result<T, NetworkServiceError>) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    func createMultipartBody(fileData: Data, fileName: String, fieldName: String, mimeType: String, parameters: [String: String], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
