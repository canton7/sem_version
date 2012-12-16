require 'sem_version/core_ext'

describe "SemVersion core exts" do
  it "should create a SemVersion using String#to_s" do
    "1.2.3-pre.4+build.5".to_version.should == SemVersion.new(1, 2, 3, 'pre.4', 'build.5')
  end
end