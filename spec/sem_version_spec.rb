require 'sem_version'

describe "SemVersion" do 
  context "when parsing a version" do 
    it "should correctly identify major, minor, build" do 
      v = SemVersion.new('0.1.2')
      v.major.should == 0
      v.minor.should == 1
      v.patch.should == 2
    end
  end
end