//
//  AlamofireDataRequestExtension.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Alamofire

extension Alamofire.DataRequest {
  /// Creates a response object with using serializer based on Decodable protocol logic.
  ///
  /// - Parameters:
  ///     - queue: queue for response processing
  ///     - completionHandler: handler closure which suppose to return decoded object.
  @discardableResult
  func responseDecodableObject<T: Decodable> (queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
    
    let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
      guard error == nil else {
        // swiftlint:disable:next force_unwrapping
        let httpKitError: HttpKit.HttpError = .httpFailure(error: error!, request: request)
        return .failure(httpKitError)
      }
      
      let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
      guard case let .success(jsonData) = result else {
        // swiftlint:disable:next force_unwrapping
        let httpKitError: HttpKit.HttpError = .jsonSerialization(error: result.error!)
        return .failure(httpKitError)
      }
      
      // (1)- Json Decoder. Decodes the data object into expected type T
      // throws error when fails
      do {
        let responseObject = try JSONDecoder().decode(T.self, from: jsonData)
        return .success(responseObject)
      } catch {
        let httpKitError: HttpKit.HttpError = .jsonDecoding(error: error)
        return .failure(httpKitError)
      }
    }
    return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
  }
  
  /// Creates a response object with using serializer based on Decodable protocol logic.
  ///
  /// - Parameters:
  ///     - queue: queue for response processing
  ///     - completionHandler: handler closure which suppose to return array of decoded objects.
  @discardableResult
  func responseDecodableCollection<T: Decodable>(queue: DispatchQueue? = nil,
                                                 completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
    
    let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
      guard error == nil else {
        // swiftlint:disable:next force_unwrapping
        let httpKitError: HttpKit.HttpError = .httpFailure(error: error!, request: request)
        return .failure(httpKitError)
      }
      
      let result = DataRequest.serializeResponseData(response: response, data: data, error: error)
      guard case let .success(jsonData) = result else {
        // swiftlint:disable:next force_unwrapping
        let httpKitError: HttpKit.HttpError = .jsonSerialization(error: result.error!)
        return .failure(httpKitError)
      }
      
      do {
        let responseArray = try JSONDecoder().decode([T].self, from: jsonData)
        return .success(responseArray)
      } catch {
        let httpKitError: HttpKit.HttpError = .jsonDecoding(error: error)
        return .failure(httpKitError)
      }
    }
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }
}
