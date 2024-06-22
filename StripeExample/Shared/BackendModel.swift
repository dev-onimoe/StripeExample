//
//  BackendModel.swift
//  AppClipExample (iOS)
//
//  Created by David Estes on 1/20/22.
//

import Foundation
import StripeApplePay

class BackendModel {
    // You can replace this with your own backend URL.
    static let backendAPIURLTourch = URL(string: "http://34.162.191.172:9239/api/card/apple-pay-test")!
    //static let backendAPIURLTourch = URL(string: "https://devapi.tourchride.com/api/card/apple-pay-test")!
    static let backendAPIURL = URL(string: "https://stripe-integration-tester.glitch.me")!

    static let returnURL = "stp-integration-tester://stripe-redirect"

    public static let shared = BackendModel()

    func fetchPaymentIntent(code: String, user_id: String, amount: Double, completion: @escaping (String?) -> Void) {
        let params: [String: Any] = [
            "code": code,
            "user_id": user_id,
            "amount": amount,
            "integration_method": "Apple Pay"
        ]
        getAPITourch(method: "createTestPayIntent", params: params) { (json) in
                if let payload = json["payload"] as? [String: Any],
                   let clientSecret = payload["client_secret"] as? String { //as? String
                    completion(clientSecret)
                   // print("json: " , clientSecret);
                } else {
                    completion(nil)
                }
            }
        
     
    }

    func loadPublishableKey(completion: @escaping (String) -> Void) {
        let params = ["integration_method": "Apple Pay"]
        getAPI(method: "get_pub_key", params: params) { (json) in
          if let publishableKey = json["publishableKey"] as? String {
            completion(publishableKey)
          } else {
            assertionFailure("Could not fetch publishable key from backend")
          }
        }
    }

    private func getAPI(method: String, params: [String: Any] = [:], completion: @escaping ([String: Any]) -> Void) {
        var request = URLRequest(url: Self.backendAPIURL.appendingPathComponent(method))
        request.httpMethod = "POST"

        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
          guard let unwrappedData = data,
                let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] else {
            if let data = data {
                print("\(String(decoding: data, as: UTF8.self))")
            } else {
                print("\(error ?? NSError())")  // swiftlint:disable:this discouraged_direct_init
            }
            return
          }
          DispatchQueue.main.async {
            completion(json)
          }
        })
        task.resume()
    }
    private func getAPITourch(method: String, params: [String: Any] = [:], completion: @escaping ([String: Any]) -> Void) {
        var request = URLRequest(url: Self.backendAPIURLTourch)
        request.httpMethod = "POST"
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
          guard let unwrappedData = data,
                let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] else {
            if let data = data {
                print("\(String(decoding: data, as: UTF8.self))")
            } else {
                print("\(error ?? NSError())")  // swiftlint:disable:this discouraged_direct_init
            }
            return
          }
          DispatchQueue.main.async {
            completion(json)
          }
        })
        task.resume()
    }
}
