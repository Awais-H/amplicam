module Support
  class MerchantNormalizer
    SUFFIXES = /\b(inc|inc\.|llc|ltd|corp|corporation|co|company)\b/i.freeze

    def self.normalize(name)
      return if name.blank?

      name
        .to_s
        .strip
        .gsub(/[^\w\s&-]/, "")
        .gsub(SUFFIXES, "")
        .squeeze(" ")
        .strip
        .downcase
        .split
        .map(&:capitalize)
        .join(" ")
    end
  end
end

