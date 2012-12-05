class SemVersion
  include Comparable
  SEMVER_REGEX = /^(\d+)\.(\d+)\.(\d+)(?:-([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?(?:\+([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?$/

  attr_accessor :major, :minor, :patch, :pre, :build

  def initialize(string)
    @major, @minor, @patch, @pre, @build = self.class.parse(string)
  end

  def self.parse(string)
    maj, min, pat, pre, bui = string.match(SEMVER_REGEX).captures
    [maj.to_i, min.to_i, pat.to_i, pre, bui]
  end

  def <=>(other)
    maj = @major <=> other.major
    return maj unless maj == 0

    min = @minor <=> other.minor
    return min unless min == 0

    pat = @patch <=> other.patch
    return pat unless pat == 0

    0
  end

  def to_s
    r = "#{@major}.#{@minor}.#{patch}"
    r << "-#{@pre}" if @pre
    r << "+#{@build}" if @build
    r
  end
end