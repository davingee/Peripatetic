require 'peripatetic'

describe Peripatetic::Locationable do
  it "broccoli is gross" do
    Peripatetic::Locationable.portray("Broccoli").should eql("Gross!")
  end

  it "anything else is delicious" do
    Peripatetic::Locationable.portray("Not Broccoli").should eql("Delicious!")
  end
end
