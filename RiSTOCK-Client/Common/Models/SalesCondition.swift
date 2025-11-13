import Foundation

enum SalesCondition: String, CaseIterable {
    case normal = "Normal"
    case notNormal = "Tidak Normal"
    case unknown = "Tidak Diketahui"
    
    var infoText: String {
        switch self {
        case .normal:
            return "**Penjualan produk** berjalan sesuai pola."
        case .notNormal:
            return "**Lonjakan ekstrem** dari periode sebelumnya."
        case .unknown:
            return "Status penjualan produk tidak diketahui."
        }
    }
}