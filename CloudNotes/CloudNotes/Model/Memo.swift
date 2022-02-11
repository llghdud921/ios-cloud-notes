import Foundation

struct Memo: Decodable {
    let title: String
    let description: String
    let lastModifiedDate: TimeInterval
    
    private enum CodingKeys: String, CodingKey {
        case title
        case description = "body"
        case lastModifiedDate = "last_modified"
    }
}
