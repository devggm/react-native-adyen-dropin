import Adyen
import AdyenNetworking
import Foundation

internal struct PaymentsRequest: Request {
    
    internal typealias ResponseType = PaymentsResponse
    
    internal typealias ErrorResponseType = PaymentsErrorResponse
    
    internal var path = "payments"
    
    internal let data: PaymentComponentData
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var headers: [String: String] = [:]
    
    init(headers: [String: String]?, queryParameters: [URLQueryItem]?, path: String?, data: PaymentComponentData) {
        if (headers != nil) {
            self.headers = headers!
        }
        
        if (queryParameters != nil) {
            self.queryParameters = queryParameters!
        }
        
        if (path != nil) {
            self.path = path!
        }
        
        self.data = data
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var amount = data.amount
        let storage = MemoryStorage.current
        
        
        if storage.minAmount != nil {
            amount = Amount(value: (storage.minAmount?[storage.paymentType!])! as Int, currencyCode: storage.amountCurrency)
        }
                
        print("storage.shopperEmail: \(storage.shopperEmail ?? "empty storage.shopperEmail")")
        
        try container.encode(data.paymentMethod.encodable, forKey: .details)
        //        try container.encode(data.storePaymentMethod, forKey: .storePaymentMethod)
        try container.encodeIfPresent(data.shopperName, forKey: .shopperName)
        try container.encodeIfPresent(storage.shopperEmail, forKey: .shopperEmail)
        try container.encodeIfPresent(data.telephoneNumber, forKey: .telephoneNumber)
        try container.encodeIfPresent(data.billingAddress, forKey: .billingAddress)
        try container.encodeIfPresent(data.deliveryAddress, forKey: .deliveryAddress)
        try container.encodeIfPresent(data.socialSecurityNumber, forKey: .socialSecurityNumber)
        try container.encode(storage.shopperLocale, forKey: .shopperLocale)
        // BrowserInfo does not provide all required info, disable
        // try container.encodeIfPresent(data.browserInfo, forKey: .browserInfo)
        try container.encode("iOS", forKey: .channel)
        try container.encode(amount, forKey: .amount)
        try container.encode(storage.countryCode, forKey: .countryCode)
        try container.encode(storage.returnUrl, forKey: .returnUrl)
        try container.encode(storage.shopperReference, forKey: .shopperReference)
        try container.encode(storage.reference, forKey: .reference)
        try container.encodeIfPresent(storage.recurringProcessingModel, forKey:.recurringProcessingModel)
        try container.encode(storage.storePaymentMethod, forKey: .storePaymentMethod)
        try container.encodeIfPresent(storage.shopperInteraction, forKey: .shopperInteraction)
        try container.encode(storage.getAdditionalData(), forKey: .additionalData)
        try container.encodeIfPresent(storage.merchantAccount, forKey: .merchantAccount)
        try container.encodeIfPresent(data.order?.compactOrder, forKey: .order)
        try container.encodeIfPresent(data.installments, forKey: .installments)
    }
    
    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case storePaymentMethod
        case amount
        case reference
        case channel
        case countryCode
        case returnUrl
        case shopperReference
        case shopperEmail
        case additionalData
        case merchantAccount
        // case browserInfo
        case shopperName
        case telephoneNumber
        case shopperLocale
        case billingAddress
        case deliveryAddress
        case socialSecurityNumber
        case order
        case installments
        case recurringProcessingModel
        case shopperInteraction
    }
    
}

internal enum StringOrFloat: Codable {
    case string(String)
    case float(Float)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Float.self) {
            self = .float(x)
            return
        }
        throw DecodingError.typeMismatch(StringOrFloat.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for StringOrFloat"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .float(let x):
            try container.encode(x)
        }
    }
}

internal enum AdditionalData: Codable {
    case object([String: StringOrFloat?])
    case array([[String: StringOrFloat?]])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String: StringOrFloat?].self) {
            self = .object(x)
            return
        }
        if let x = try? container.decode([[String: StringOrFloat?]].self) {
            self = .array(x)
            return
        }
        throw DecodingError.typeMismatch(AdditionalData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for AdditionalData"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .object(let x):
            try? container.encode(x)
        case .array(let x):
            try? container.encode(x)
        }
    }
}

internal struct PaymentsResponse: Response {
    
    internal let resultCode: ResultCode
    
    internal let action: Action?
    
    internal let order: PartialPaymentOrder?
    
    internal let refusalReason: String?
    
    internal let refusalReasonCode: String?
    
    internal let pspReference: String?
    
    internal let merchantReference: String?
    
    internal let additionalData: AdditionalData?
    
    internal let paymentType: String?
    
    internal let errorCode: String?
    
    internal let message: String?
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.resultCode = try container.decode(ResultCode.self, forKey: .resultCode)
        self.action = try container.decodeIfPresent(Action.self, forKey: .action)
        self.order = try container.decodeIfPresent(PartialPaymentOrder.self, forKey: .order)
        
        self.refusalReason = try container.decodeIfPresent(String.self, forKey: .refusalReason)
        self.refusalReasonCode = try container.decodeIfPresent(String.self, forKey: .refusalReasonCode)
        self.pspReference = try container.decodeIfPresent(String.self, forKey: .pspReference)
        self.merchantReference = try container.decodeIfPresent(String.self, forKey: .merchantReference)
        self.additionalData = try container.decodeIfPresent(AdditionalData.self, forKey: .additionalData)
        self.paymentType =  MemoryStorage.current.paymentType
        self.errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
    private enum CodingKeys: String, CodingKey {
        case refusalReason
        case refusalReasonCode
        case additionalData
        case errorCode
        case message
        case resultCode
        case action
        case order
        case merchantReference
        case pspReference
        case paymentType
    }
    
}

extension PaymentsResponse: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(refusalReason, forKey: .refusalReason)
        try container.encode(resultCode.rawValue, forKey: .resultCode)
        
        try container.encode(refusalReasonCode, forKey: .refusalReasonCode)
        try container.encode(additionalData, forKey: .additionalData)
        try container.encode(paymentType, forKey: .paymentType)
        try container.encode(merchantReference, forKey: .merchantReference)
        try container.encode(pspReference, forKey: .pspReference)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encode(message, forKey: .message)
    }
}
