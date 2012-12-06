class SemVersion
  include Comparable

  VERSION = '0.1.0'
  SEMVER_REGEX = /^(\d+)\.(\d+)\.(\d+)(?:-([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?(?:\+([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?$/

  attr_accessor :major, :minor, :patch, :pre, :build

  def initialize(string)
    @major, @minor, @patch, @pre, @build = self.class.parse(string)
  end

  def self.parse(string)
    match = string.match(SEMVER_REGEX)
    raise ArgumentError, "Version string #{string} is not valid" unless match
    maj, min, pat, pre, bui = match.captures
    [maj.to_i, min.to_i, pat.to_i, pre, bui]
  end

  def self.valid?(string)
    !!(string =~ SEMVER_REGEX)
  end

  def <=>(other)
    maj = @major <=> other.major
    return maj unless maj == 0

    min = @minor <=> other.minor
    return min unless min == 0

    pat = @patch <=> other.patch
    return pat unless pat == 0

    pre = compare_sep(@pre, other.pre, true)
    return pre unless pre == 0

    bui = compare_sep(@build, other.build, false)
    return bui unless bui == 0

    0
  end

  def satisfies?(constraint)
    comparison, version = constraint.strip.split(' ', 2)
    # Allow '1.0.2' as '== 1.0.2'
    version, comparison = comparison, '==' if version.nil?
    # Allow '= 1.0.2' as '== 1.0.2'
    comparison = '==' if comparison == '='
    # Allow pessimistic operator
    if comparison == '~>'
      match = version.match(/^(\d+)\.(\d+)\.?(\d*)$/)
      raise ArgumentError, "Pessimistic constraints must have a version in the form 'x.y' or 'x.y.z'" unless match
      maj, min, pat = match.captures
      if pat.empty?
        lower = "#{maj}.#{min}.0"
        upper = "#{maj.to_i+1}.0.0"
      else
        lower = "#{maj}.#{min}.#{pat}"
        upper = "#{maj}.#{min.to_i+1}.0"
      end

      send('>=', SemVersion.new(lower)) && send('<', SemVersion.new(upper)) 
    else
      send(comparison, SemVersion.new(version))
    end
  end

  def to_s
    r = "#{@major}.#{@minor}.#{patch}"
    r << "-#{@pre}" if @pre
    r << "+#{@build}" if @build
    r
  end

  private
  
  def compare_sep(ours, theirs, nil_wins)
    # Both nil? They're equal
    return 0 if ours.nil? && theirs.nil?
    # One's nil? The winner is determined by precidence
    return nil_wins ? -1 : 1 if theirs.nil?
    return nil_wins ? 1 : -1 if ours.nil?

    our_parts = ours.split('.')
    their_parts = theirs.split('.')

    our_parts.zip(their_parts) do |a,b|
      # b can be nil, in which case it loses
      return 1 if b.nil?
      # If they're both ints, convert to as such
      # If one's an int and the other isn't, the string version of the int gets correctly compared
      a, b = a.to_i, b.to_i if a =~ /^\d+$/ && b =~ /^\d+$/

      comp = a <=> b
      return comp unless comp == 0
    end

    # If we got this far, either they're equal (same length) or they won
    return (our_parts.length == their_parts.length) ? 0 : -1
  end
end