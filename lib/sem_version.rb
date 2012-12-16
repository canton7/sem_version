class SemVersion
  include Comparable

  VERSION = '1.3.0'

  # Pattern allows min and patch to be skipped. We have to do extra checking if we want them
  SEMVER_REGEX = /^(\d+)(?:\.(\d+)(?:\.(\d+)(?:-([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?(?:\+([\dA-Za-z\-]+(?:\.[\dA-Za-z\-]+)*))?)?)?$/
  PRE_BUILD_REGEX = /^[\dA-Za-z\-]+(\.[\dA-Za-z\-]+)*$/

  attr_reader :major, :minor, :patch, :pre, :build
  alias_method :prerelease, :pre

  # Format were raw bits are passed in is undocumented, and not validity checked
  def initialize(*args)
    if args.first.is_a?(String)
      @major, @minor, @patch, @pre, @build = self.class.parse(args.first)
      # Validation should be handled at a string level by self.parse, but validate anyway
      validate
    elsif args.first.is_a?(Hash)
      @major, @minor, @patch, @pre, @build = args.first.values_at(:major, :minor, :patch, :pre, :build)
      # Allow :prerelease as well
      @pre ||= args.first[:prerelease]
      validate
    elsif args.first.is_a?(Array)
      @major, @minor, @patch, @pre, @build = *args.first
      validate
    else
      @major, @minor, @patch, @pre, @build = *args
      validate
    end
  end

  def self.parse(string)
    match = string.match(SEMVER_REGEX)
    raise ArgumentError, "Version string #{string} is not valid" unless match
    maj, min, pat, pre, bui = match.captures
    raise ArgumentError, "Version string #{string} is not valid" if min.empty? || pat.empty?
    [maj.to_i, min.to_i, pat.to_i, pre, bui]
  end

  def self.from_loose_version(string)
    match = string.match(SEMVER_REGEX)
    raise ArgumentError, "Version string #{string} is not valid" unless match
    maj, min, pat, pre, bui = match.captures
    min = 0 if min.nil? || min.empty?
    pat = 0 if pat.nil? || pat.empty?
    new(maj.to_i, min.to_i, pat.to_i, pre, bui)
  end

  def self.valid?(string)
    matches = string.match(SEMVER_REGEX)
    matches && !matches[2].nil? && !matches[3].nil?
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
    comparison, version = self.class.split_constraint(constraint)
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
      comparison = '==' if comparison == '='
      semversion = self.class.from_loose_version(version)
      send(comparison, semversion)
    end
  end

  def self.open_constraint?(constraint)
    comparison, _ = self.split_constraint(constraint)
    comparison != '='
  end

  def self.split_constraint(constraint)
    comparison, version = constraint.strip.split(' ', 2)
    comparison, version = '=', comparison if version.nil?
    comparison = '=' if comparison == '=='
    [comparison, version]
  end

  def major=(val)
    raise ArgumentError, "#{val} is not a valid major version (must be an integer >= 0)" unless val.is_a?(Fixnum) && val >= 0
    @major = val
  end

  def minor=(val)
    raise ArgumentError, "#{val} is not a valid minor version (must be an integer >= 0)" unless val.is_a?(Fixnum) && val >= 0
    @minor = val
  end

  def patch=(val)
    raise ArgumentError, "#{val} is not a valid patch version (must be an integer >= 0)" unless val.is_a?(Fixnum) && val >= 0
    @patch = val
  end

  def pre=(val)
    unless val.nil? || (val.is_a?(String) && val =~ PRE_BUILD_REGEX)
      raise ArgumentError, "#{val} is not a valid pre-release version (must be nil, or a string following http://semver.org constraints)"
    end
    @pre = val
  end
  alias_method :prerelease=, :pre=

  def build=(val)
    unless val.nil? || (val.is_a?(String) && val =~ PRE_BUILD_REGEX)
      raise ArgumentError, "#{val} is not a valid build version (must be nil, or a string following http://semver.org constraints)"
    end
    @build = val
  end

  def to_s
    r = "#{@major}.#{@minor}.#{@patch}"
    r << "-#{@pre}" if @pre
    r << "+#{@build}" if @build
    r
  end

  def to_a
    [@major, @minor, @patch, @pre, @build]
  end

  def to_h
    h = [:major, :minor, :patch, :pre, :build].zip(to_a)
    Hash[h.reject{ |k,v| v.nil? }]
  end

  def inspect
    "#<SemVersion: #{to_s}>"
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

  def validate
    # Validates the instance variables. Different approach to validating a raw string
    raise ArgumentError, "Invalid version (major is not an int >= 0)" unless @major.is_a?(Fixnum) && @major >= 0
    raise ArgumentError, "Invalid version (minor is not an int >= 0)" unless @minor.is_a?(Fixnum) && @minor >= 0
    raise ArgumentError, "Invalid version (patch is not an int >= 0)" unless @patch.is_a?(Fixnum) && @patch >= 0
    unless @pre.nil? || (@pre.is_a?(String) && @pre =~ PRE_BUILD_REGEX)
      raise ArgumentError, "Invalid version (pre must be nil, or a string following http://semver.org contraints)"
    end
    unless @build.nil? || (@build.is_a?(String) && @build =~ PRE_BUILD_REGEX)
      raise ArgumentError, "Invalid version (build must be nil, or a string following http://semver.org contraints)"
    end
  end
end

def SemVersion(*args)
  SemVersion.new(*args)
end