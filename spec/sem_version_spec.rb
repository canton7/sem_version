require 'sem_version'

describe "SemVersion" do 
  context "when parsing a version" do 
    it "should correctly identify major, minor, build" do 
      v = SemVersion.new('0.1.2')
      v.major.should == 0
      v.minor.should == 1
      v.patch.should == 2
    end

    it "should correctly identify the pre-release" do 
      v = SemVersion.new('0.1.2-three.4-5')
      v.pre.should == 'three.4-5'
    end

    it "should correctly identify the build" do 
      v1 = SemVersion.new('0.1.2+build.4.5')
      v2 = SemVersion.new('0.1.2-pre.four+five.6')

      v1.build.should == 'build.4.5'
      v2.build.should == 'five.6'
    end
  end

  context "when generating version strings" do 
    it "do x.y.z correctly" do 
      SemVersion.new('1.2.3').to_s.should == '1.2.3'
    end

    it "should do x.y.z-pre" do 
      SemVersion.new('3.2.1-pre.4').to_s.should == '3.2.1-pre.4'
    end

    it "should do x.y.z+build" do 
      SemVersion.new('1.2.3+build.4.five').to_s.should == '1.2.3+build.4.five'
    end

    it "should do x.y.z-pre+build" do 
      SemVersion.new('3.2.1-pre.4+build.5.six').to_s.should == '3.2.1-pre.4+build.5.six'
    end
  end

  context "when comparing versions" do 
    it "should compare patch correctly" do 
      SemVersion.new('0.0.1').should be == SemVersion.new('0.0.1')
      SemVersion.new('0.0.1').should be < SemVersion.new('0.0.2')
      SemVersion.new('0.0.1').should be < SemVersion.new('0.0.20')
    end

    it "should compare minor correctly" do 
      SemVersion.new('0.1.0').should be == SemVersion.new('0.1.0')
      SemVersion.new('0.1.0').should be < SemVersion.new('0.1.1')
      SemVersion.new('0.1.0').should be < SemVersion.new('0.1.10')
    end

    it "should compare major correctly" do 
      SemVersion.new('1.0.0').should be == SemVersion.new('1.0.0')
      SemVersion.new('1.0.0').should be < SemVersion.new('2.0.0')
      SemVersion.new('1.0.0').should be < SemVersion.new('20.0.0')
    end

    it "should compare pre correctly" do 
      SemVersion.new('1.0.0-pre').should be == SemVersion.new('1.0.0-pre')
      SemVersion.new('1.0.0').should be > SemVersion.new('1.0.0-pre')
      SemVersion.new('1.0.0-alpha').should be < SemVersion.new('1.0.0-beta')
      SemVersion.new('1.0.0-1').should be < SemVersion.new('1.0.0-2')
      SemVersion.new('1.0.0-2').should be < SemVersion.new('1.0.0-11')
      SemVersion.new('1.0.0-a').should be > SemVersion.new('1.0.0-100')
      SemVersion.new('1.0.0-a.3.b').should be < SemVersion.new('1.0.0-a.3.c')
      SemVersion.new('1.0.0-a.4.b').should be > SemVersion.new('1.0.0-a.3.c')
      SemVersion.new('1.0.0-a.3.b').should be > SemVersion.new('1.0.0-a.3')
      SemVersion.new('1.0.0-a.3').should be < SemVersion.new('1.0.0-a.3.3')
    end

    it "should compare build correctly" do 
      SemVersion.new('1.0.0-pre+build').should be == SemVersion.new('1.0.0-pre+build')
      SemVersion.new('1.0.0+build').should be == SemVersion.new('1.0.0+build')
      SemVersion.new('1.0.0+build').should be > SemVersion.new('1.0.0')
      SemVersion.new('1.0.0+alpha').should be < SemVersion.new('1.0.0+beta')
      SemVersion.new('1.0.0+1').should be < SemVersion.new('1.0.0+2')
      SemVersion.new('1.0.0+2').should be < SemVersion.new('1.0.0+11')
      SemVersion.new('1.0.0+a').should be > SemVersion.new('1.0.0+100')
      SemVersion.new('1.0.0+a.3.b').should be < SemVersion.new('1.0.0+a.3.c')
      SemVersion.new('1.0.0+a.4.b').should be > SemVersion.new('1.0.0+a.3.c')
      SemVersion.new('1.0.0+a.3.b').should be > SemVersion.new('1.0.0+a.3')
      SemVersion.new('1.0.0+a.3').should be < SemVersion.new('1.0.0+a.3.3')
    end

    it "should pass the semver.org test cases" do 
      SemVersion.new('1.0.0-alpha').should be < SemVersion.new('1.0.0-alpha.1')
      SemVersion.new('1.0.0-alpha.1').should be < SemVersion.new('1.0.0-beta.2')
      SemVersion.new('1.0.0-beta.2').should be < SemVersion.new('1.0.0-beta.11')
      SemVersion.new('1.0.0-beta.11').should be < SemVersion.new('1.0.0-rc.1')
      SemVersion.new('1.0.0-rc.1').should be < SemVersion.new('1.0.0-rc.1+build.1')
      SemVersion.new('1.0.0-rc.1+build.1').should be < SemVersion.new('1.0.0')
      SemVersion.new('1.0.0').should be < SemVersion.new('1.0.0+0.3.7')
      SemVersion.new('1.0.0+0.3.7').should be < SemVersion.new('1.3.7+build')
      SemVersion.new('1.3.7+build').should be < SemVersion.new('1.3.7+build.2.b8f12d7')
      SemVersion.new('1.3.7+build.2.b8f12d7').should be < SemVersion.new('1.3.7+build.11.e0f985a')
    end
  end

  context "when satisfying constraints" do
    it "should correctly satisfy >" do 
      SemVersion.new('1.0.1').satisfies?('> 1.0.0').should be_true
      SemVersion.new('1.0.1').satisfies?('> 1.0.1').should be_false
    end

    it "should correctly satisfy >=" do 
      SemVersion.new('1.0.1').satisfies?('>= 1.0.0').should be_true
      SemVersion.new('1.0.1').satisfies?('>= 1.0.1').should be_true
      SemVersion.new('1.0.1').satisfies?('>= 1.0.2').should be_false
    end

    it "should correctly satisfy <" do 
      SemVersion.new('1.0.1').satisfies?('< 1.0.2').should be_true
      SemVersion.new('1.0.1').satisfies?('< 1.0.1').should be_false
    end

    it "should correctly satisfy <=" do 
      SemVersion.new('1.0.1').satisfies?('<= 1.0.2').should be_true
      SemVersion.new('1.0.1').satisfies?('<= 1.0.1').should be_true
      SemVersion.new('1.0.1').satisfies?('<= 1.0.0').should be_false
    end

    it "should correctly satisfy =" do 
      SemVersion.new('1.0.1').satisfies?('= 1.0.1').should be_true
      SemVersion.new('1.0.1').satisfies?('1.0.1').should be_true
      SemVersion.new('1.0.1').satisfies?('= 1.0.2').should be_false
    end

    it "should correctly satisfy ~> x.y" do 
      SemVersion.new('2.1.9').satisfies?('~> 2.2').should be_false
      SemVersion.new('2.2.0').satisfies?('~> 2.2').should be_true
      SemVersion.new('2.9.0').satisfies?('~> 2.2').should be_true
      SemVersion.new('3.0.0').satisfies?('~> 2.2').should be_false
    end

    it "should correctly satisfy ~> x.y.z" do 
      SemVersion.new('2.1.9').satisfies?('~> 2.2.0').should be_false
      SemVersion.new('2.2.0').satisfies?('~> 2.2.0').should be_true
      SemVersion.new('2.3.0').satisfies?('~> 2.2.0').should be_false
    end
  end
end