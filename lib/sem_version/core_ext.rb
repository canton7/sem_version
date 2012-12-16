# Just make sure sem_version has been required
require 'sem_version'

class String
  def to_version
    SemVersion.new(self)
  end
end