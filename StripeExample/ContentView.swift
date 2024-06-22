//
//  ContentView.swift
//  StripeExample
//
//  Created by Masud Onikeku on 20/06/2024.
//

//

import StripeApplePay
import SwiftUI

struct ContentView: View {
    @StateObject var model = MyApplePayBackendModel()
    @State var ready = false

    var body: some View {
        if ready {
            VStack {
                PaymentButton {
                  model.pay()
                }
                .padding()
              if let paymentStatus = model.paymentStatus {
                PaymentStatusView(status: paymentStatus, lastPaymentError: model.lastPaymentError)
              }
            }
        } else {
            ProgressView().onAppear {
                BackendModel.shared.loadPublishableKey { pubKey in
                    STPAPIClient.shared.publishableKey = "pk_test_51OjNbjDxx0KtNcqufscqdA54j3F1cXyyT46T3ycBK8FJilp9cEyOM4my2dSdS7T6eLDOnLmjsO907bYJnhsX9iPF00uRMJqweE"
                    
                    //test devapi stripe key
                  /* STPAPIClient.shared.publishableKey = "pk_test_51JwAV4FXLiXvGSAMbQ1fL7IUtEjSBuWKxGOqOBSPSc4zGR8qFEC0ln1HtJjmLxwNEvE2g3EqCXCT1X5nudVWzaBx00u3LSw23w" */
                  
                     ready = true
                }
            }
        }
    }
}

struct PaymentStatusView: View {
  let status: STPApplePayContext.PaymentStatus
  var lastPaymentError: Error?

  var body: some View {
     HStack {
      switch status {
      case .success:
        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        Text("Payment complete!")
      case .error:
        Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
        Text("Payment failed! \(lastPaymentError.debugDescription)")
      case .userCancellation:
        Image(systemName: "xmark.octagon.fill").foregroundColor(.orange)
        Text("Payment canceled.")
      }
    }
    .accessibility(identifier: "Payment status view")
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

