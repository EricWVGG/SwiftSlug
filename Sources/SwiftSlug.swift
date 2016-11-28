import Foundation

enum SlugConversionError: Error {
	case failedToConvert
}

extension String {
	private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

	@available(OSX 10.11, *)
	public func convertedToSlug() throws -> String {
		var result: String? = nil

		#if os(Linux)
			// On Linux StringTransform doesn't exist and CFStringTransform causes all sorts
			// of problems because of bridging issues using CFMutableString – d'oh.
			// So we're going to do the only thing possible: dump to ASCII and hope for the best
			if let data = self.data(using: .ascii, allowLossyConversion: true) {
				if let str = String(data: data, encoding: .ascii) {
					let urlComponents = str.lowercased().components(separatedBy: String.slugSafeCharacters.inverted)
					result = urlComponents.filter { $0 != "" }.joined(separator: "-")
				}
			}
		#else
			if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
				let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
				result = urlComponents.filter { $0 != "" }.joined(separator: "-")
			}
		#endif

		if let result = result {
			if result.characters.count > 0 {
				return result
			}
		}

		throw SlugConversionError.failedToConvert
	}
}