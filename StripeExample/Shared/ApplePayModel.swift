//
//  ApplePayModel.swift
//  IntegrationTester
//
//  Created by David Estes on 2/18/21.
//

import Foundation
import PassKit
import StripeApplePay

class MyApplePayBackendModel: NSObject, ObservableObject, ApplePayContextDelegate {
    @Published var paymentStatus: STPApplePayContext.PaymentStatus?
  @Published var lastPaymentError: Error?

  func pay() {
    // Configure a payment request
    let pr = StripeAPI.paymentRequest(withMerchantIdentifier: "merchant.com.tourchtest", country: "US", currency: "USD")
      
      //merchant.com.tourchtest
      //merchant.com.tourchride
    // You'd generally want to configure at least `.postalAddress` here.
    // We don't require anything here, as we don't want to enter an address
    // in CI.
    pr.requiredShippingContactFields = []
    pr.requiredBillingContactFields = []

    // Configure shipping methods
    let firstClassShipping = PKShippingMethod(label: "First Class Mail", amount: NSDecimalNumber(string: "10.99"))
    firstClassShipping.detail = "Arrives in 3-5 days"
    firstClassShipping.identifier = "firstclass"
    let rocketRidesShipping = PKShippingMethod(label: "Rocket Rides courier", amount: NSDecimalNumber(string: "10.99"))
    rocketRidesShipping.detail = "Arrives in 1-2 hours"
    rocketRidesShipping.identifier = "rocketrides"
    pr.shippingMethods = [
      firstClassShipping,
      rocketRidesShipping,
    ]

    // Build payment summary items
    // (You'll generally want to configure these based on the selected address and shipping method.
    pr.paymentSummaryItems = [
      PKPaymentSummaryItem(label: "A very nice computer", amount: NSDecimalNumber(string: "19.99")),
      PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(string: "10.99")),
      PKPaymentSummaryItem(label: "Stripe Computer Shop", amount: NSDecimalNumber(string: "29.99")),
    ]

    // Present the Apple Pay Context:
    let applePayContext = STPApplePayContext(paymentRequest: pr, delegate: self)
    applePayContext?.presentApplePay()
  }

    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
      
        let code = "EN" //
        let user_id = "DRI170903970996"
        let amount: Double = 10.99

        // When the Apple Pay sheet is confirmed, create a PaymentIntent on your backend from the provided PKPayment information.
        
       
        BackendModel.shared.fetchPaymentIntent(code: code, user_id: user_id, amount: amount) { secret in
            if let clientSecret = secret {
                // Call the completion block with the PaymentIntent's client secret.
                print("clientSecret:"  + clientSecret);
                
        
                completion(clientSecret, nil)
            } else {
                completion(nil, NSError())  // swiftlint:disable:this discouraged_direct_init
            }
        }
    }


    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPApplePayContext.PaymentStatus, error: Error?) {
        // When the payment is complete, display the status.
        self.paymentStatus = status
        self.lastPaymentError = error
    }
}
