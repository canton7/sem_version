class SemVersion
  SEMVER_REGEX = /^(\d+)\.(\d+)\.(\d+)(?:-([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?(?:\+([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?$/

  attr_accessor :major, :minor, :patch, :pre, :build

  def initialize(string)
    @major, @minor, @patch, @pre, @build = self.class.parse(string)
  end

  def self.parse(string)
    maj, min, pat, pre, bui = string.match(SEMVER_REGEX).captures
    [maj.to_i, min.to_i, pat.to_i, pre, bui]
  end
end