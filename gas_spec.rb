require 'gas'
require 'rubygems'
require 'spec'

describe "Gas.request_url" do
  it "should raise an error without a next option" do
    lambda{GAS.request_url :scope => "http://www.blogger.com/feeds/"}.should raise_error(ArgumentError)
  end
  it "should raise an error without a scope option" do
    lambda{GAS.request_url :next => "http://www.myapp.com/"}.should raise_error(ArgumentError)
  end
  it "should default to an insecure request" do
    url = GAS.request_url :next => "http://myapp.com", :scope => "http://www.blogger.com/feeds/"
    url.should =~ /secure=0/
  end
  it "shopuld make a secure request if asked" do
    url = GAS.request_url :next => "http://myapp.com", :scope => "http://www.blogger.com/feeds/", :secure => true
    url.should =~ /secure=1/
  end
end

describe "GAS.create_session_token with success" do
  before do
    GAS.stub!(:securely_get).and_return(@r = mock("Response"))
    @r.stub!(:body).and_return("Token=CJvSipr9ERCflKrpBg\n")
    @r.stub!(:code).and_return("200")
    @asr_token = "D3ADB33F"
  end

  it "should make a secure GET request to the right google url with the right auth headers" do
    GAS.should_receive(:securely_get).with("https://www.google.com/accounts/AuthSubSessionToken", {"Authorization" => 'AuthSub token="'+ @asr_token +'"'}).and_return(@r)
    GAS.create_session_token @asr_token
  end
  
  it "should return the token as a string" do
    GAS.create_session_token( @asr_token ).should == "CJvSipr9ERCflKrpBg" 
  end
end

describe "GAS.create_session_token with failure" do
  before do
    GAS.stub!(:securely_get).and_return(@r = mock("Response"))
    @r.stub!(:code).and_return("403")
    @asr_token = "D3ADB33F"
  end
  
  it "should return false" do
    GAS.create_session_token @asr_token
  end
end