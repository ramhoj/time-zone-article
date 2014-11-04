# Configured time zone is "Kabul" which is +04:30 ahead of UTC.
# Time is by default frozen at "2014-03-15T23:31:11+05:45" (Kathmandu time zone)

describe Article, frozen: "2014-03-15T23:31:11+05:45" do
  describe ActiveSupport::Duration do
    describe "#ago" do
      it "returns the time what the time was 2 minutes ago in Kabul time" do
        expect(2.minutes.ago.iso8601).to eq("2014-03-15T22:14:11+04:30")
      end
    end
  end
end
