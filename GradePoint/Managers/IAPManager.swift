//
//  IAPManager.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductPurchaseCompletionHandler = (_ success: Bool) -> Void
public typealias ProductRestoreCompletionHandler = (_ success: Bool) -> Void

/**
 A manager which handles in app purchases in GradePoint.
 */
public class IAPManager: NSObject {
    static let IAPManagerPurchaseNotification: String = "IAPManagerPurchaseNotification"

    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductRequestCompletionHandler?
    private var productPurchaseCompletionHandler: ProductPurchaseCompletionHandler?
    private var productRestoreCompletionHandler: ProductRestoreCompletionHandler?

    public init(productIds: Set<ProductIdentifier>) {
        self.productIdentifiers = productIds
        for productId in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productId)
            if purchased {
                print("Previously purchased IAP: \(productId)")
            } else {
                print("Never purchased IAP: \(productId)")
            }
        }

        super.init()
        SKPaymentQueue.default().add(self)
    }
}

// MARK: StoreKit API

extension IAPManager {

    public func requestProducts(completionHandler: @escaping ProductRequestCompletionHandler) {
        self.productsRequest?.cancel()
        self.productsRequestCompletionHandler = completionHandler

        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }

    public func buyProduct(_ product: SKProduct, completion: @escaping ProductPurchaseCompletionHandler) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        self.productPurchaseCompletionHandler = completion
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases(completion: @escaping ProductRestoreCompletionHandler) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.productRestoreCompletionHandler = completion
    }
}

// MARK: SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {

    private func clearRequestAndHandler() {
        self.productsRequest = nil
        self.productsRequestCompletionHandler = nil
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        self.productsRequestCompletionHandler?(true, products)
        self.clearRequestAndHandler()

        for product in products {
            print("Found product: \(product.productIdentifier) \(product.localizedTitle) $\(product.price.floatValue)")
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products")
        print("Error: \(error.localizedDescription)")
        self.productsRequestCompletionHandler?(false, nil)
        self.clearRequestAndHandler()
    }
}

// MARK: SKPaymentTransactionObserver

extension IAPManager: SKPaymentTransactionObserver {

    private func deliverPurchaseNotification(forIdentifier id: String?) {
        guard let id = id else { return }
        self.purchasedProductIdentifiers.insert(id)
        UserDefaults.standard.set(true, forKey: id)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPManager.IAPManagerPurchaseNotification), object: id)
    }

    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        print("Transaction complete: \(String(describing: transaction.transactionIdentifier))")
        self.deliverPurchaseNotification(forIdentifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        self.productPurchaseCompletionHandler?(true)
    }

    private func failTransaction(_ transaction: SKPaymentTransaction) {
        print("Transaction failed: \(String(describing: transaction.transactionIdentifier))")
        if let error = transaction.error as NSError? {
            if error.code != SKError.paymentCancelled.rawValue {
                print("Transaction error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        self.productPurchaseCompletionHandler?(false)
    }

    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        guard let productId = transaction.original?.payment.productIdentifier else { return }
        print("Transaction restored: \(String(describing: transaction.transactionIdentifier))")
        self.deliverPurchaseNotification(forIdentifier: productId)
        SKPaymentQueue.default().finishTransaction(transaction)
        self.productRestoreCompletionHandler?(true)
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.completeTransaction(transaction)
            case .failed:
                self.failTransaction(transaction)
            case .restored:
                self.restoreTransaction(transaction)
            default: return
            }
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            print("Unable to resotre rpoduct, error: \(error.localizedDescription)")
            self.productRestoreCompletionHandler?(false)
        }
    }
}















