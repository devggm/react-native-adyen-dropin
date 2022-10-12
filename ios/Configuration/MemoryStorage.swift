import Adyen
class MemoryStorage {
    static let current = MemoryStorage()
    
    private init() {}
    
    // MARK: - RN module related
    var baseUrl: URL? = nil
    
    var debug: Bool = false
    
    var disableNativeRequests: Bool = false
    
    var headers: [String: String]? = nil
    
    var queryParameters: [URLQueryItem]? = nil
    
    var makePaymentEndpoint: String = "payments"
    
    var makeDetailsCallEndpoint: String = "payments/details"
    
    var disableStoredPaymentMethodEndpoint: String = "disable"
    
    // MARK: - Adyen DropIn related
    
    var clientKey: String? = nil
    
    var shopperReference: String? = nil
    
    var reference: String? = nil
    
    var countryCode: String? = nil
    
    var amountValue: Int = 0
    
    var amountCurrency: String = "EUR"
    
    var shopperLocale: String = Locale.current.identifier
    
    var allow3DS2: Bool = true
    
    var executeThreeD: Bool = true
    
    var returnUrl: String?

    var merchantAccount: String?
    
    var recurringProcessingModel:String?
    
    var storePaymentMethod: Bool = false
    
    var shopperInteraction: String?
    
    var paymentType: String? = ""
    
    var minAmount:  [String: Int]? = nil
    
    var shopperEmail: String?

    func getAdditionalData() -> [String: Bool] {
        return ["allow3DS2": allow3DS2, "executeThreeD": executeThreeD]
    }
}
