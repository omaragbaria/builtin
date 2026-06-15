import Foundation

enum Endpoint {
    // Auth
    case login
    case logout
    case userByEmail(email: String)

    // Items
    case items
    case item(id: Int)
    case itemPhotos(id: Int)
    case itemLocations(id: Int)
    case itemPrices(id: Int)
    case providerItems(providerId: Int)
    case createItem
    case updateItem(id: Int)

    // Providers
    case providers
    case provider(id: Int)
    case providerLocations(providerId: Int)
    case createProviderLocation(providerId: Int)
    case deleteProviderLocation(providerId: Int, locationId: Int)

    // Deals
    case checkout
    case dealItems(dealId: Int)
    case userDeals(userId: Int)

    // Deliveries
    case deliveries
    case pendingDeliveries
    case deliveriesByAccount(accountId: Int)
    case delivery(id: Int)
    case acceptDelivery(id: Int)
    case updateDeliveryStage(id: Int)
    case updateDeliveryEta(id: Int)
    case deliveryByDeal(dealId: Int)
    case updateDriverLocation

    // Delivery Accounts
    case deliveryAccounts
    case deliveryAccountByEmail(email: String)
    case updateDeliveryAccountLocation(id: Int)

    // Tools
    case calculatorCalculate
    case agentCalculate

    // Photos proxy
    case photo(filename: String)

    var path: String {
        switch self {
        case .login:                                    return "/auth/login"
        case .logout:                                   return "/auth/logout"
        case .userByEmail(let email):                   return "/users/by-email/\(email)"
        case .items:                                    return "/items"
        case .item(let id):                             return "/items/\(id)"
        case .itemPhotos(let id):                       return "/items/\(id)/photos"
        case .itemLocations(let id):                    return "/items/\(id)/locations"
        case .itemPrices(let id):                       return "/items/\(id)/prices"
        case .providerItems(let id):                    return "/items/provider/\(id)"
        case .createItem:                               return "/items"
        case .updateItem(let id):                       return "/items/\(id)"
        case .providers:                                return "/providers"
        case .provider(let id):                         return "/providers/\(id)"
        case .providerLocations(let id):                return "/providers/\(id)/locations"
        case .createProviderLocation(let id):           return "/providers/\(id)/locations"
        case .deleteProviderLocation(let pId, let lId): return "/providers/\(pId)/locations/\(lId)"
        case .checkout:                                 return "/deals/checkout"
        case .dealItems(let id):                        return "/deals/\(id)/items"
        case .userDeals(let id):                        return "/deals/user/\(id)"
        case .deliveries:                               return "/deliveries"
        case .pendingDeliveries:                        return "/deliveries/pending"
        case .deliveriesByAccount(let id):              return "/deliveries/account/\(id)"
        case .delivery(let id):                         return "/deliveries/\(id)"
        case .acceptDelivery(let id):                   return "/deliveries/\(id)/accept"
        case .updateDeliveryStage(let id):              return "/deliveries/\(id)/stage"
        case .updateDeliveryEta(let id):                return "/deliveries/\(id)/eta"
        case .deliveryByDeal(let id):                   return "/deliveries/deal/\(id)"
        case .updateDriverLocation:                     return "/deliveries/location"
        case .deliveryAccounts:                         return "/delivery-accounts"
        case .deliveryAccountByEmail(let email):        return "/delivery-accounts/by-email/\(email)"
        case .updateDeliveryAccountLocation(let id):    return "/delivery-accounts/\(id)/location"
        case .calculatorCalculate:                      return "/calculator/calculate"
        case .agentCalculate:                           return "/agent/calculate"
        case .photo(let filename):                      return "/photos/\(filename)"
        }
    }

    var url: URL {
        URL(string: Config.baseURL.absoluteString + path)!
    }
}
