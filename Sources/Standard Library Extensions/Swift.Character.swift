extension Swift.Character {

    /// The ASCII C0 separators, lowest to highest: unit within record, record within group,
    /// group within file, file. The unit separator joins free text safely: it appears in none.
    public static let unitSeparator: Character = "\u{1F}"

    public static let recordSeparator: Character = "\u{1E}"

    public static let groupSeparator: Character = "\u{1D}"

    public static let fileSeparator: Character = "\u{1C}"
}
