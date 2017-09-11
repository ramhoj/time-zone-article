#
# The goal with this test suite is not to have test coverage for every edge case in all Ruby and ActiveSupport's
# methods but rahter verify that the examples in the article are still up-to-date. The below specification could
# also be used to better understand the examples in the article.
#
# Feel free to fork and add more test cases that suites your use case. If you think your addition is benificial
# for others please consider sending a pull request!
#
# Configured time zone is "Kabul" which is +04:30 ahead of UTC.
# Time is by default frozen at "2014-03-15T23:31:11+05:45" (Kathmandu time zone)
#

describe Article, frozen: "2014-03-15T23:31:11+05:45" do
  describe ActiveRecord::Base do
    describe ".where" do
      it "converts times to UTC database format" do
        created_at = Time.zone.parse("2014-03-16T23:32:11+06:00")
        article = Article.create!(created_at: created_at.in_time_zone("Adelaide"))

        expect(Article.where(created_at: created_at.in_time_zone("Chatham Is.")).first!).to eq(article)
      end
    end

    describe "#created_at" do
      let!(:article) { Article.create! }

      it "returns the time the article was created in Kabul time" do
        expect(article.created_at.iso8601).to eq("2014-03-15T22:16:11+04:30")
      end

      it "remains the same when fetch from the database" do
        expect(Article.find(article.id).created_at.iso8601).to eq("2014-03-15T22:16:11+04:30")
      end

      it "is stored as UTC" do
        expect(Article.find(article.id).created_at_before_type_cast).to eq("2014-03-15 17:46:11")
      end

      it "can be updated with any time zone time" do
        article.update_attributes!(created_at: "2014-03-16T23:32:11+06:00")
        expect(Article.find(article.id).created_at.iso8601).to eq("2014-03-16T22:02:11+04:30")
      end
    end
  end

  describe ActiveSupport::TimeZone do
    context "time zone is Kabul" do
      describe "#parse" do
        it "returns the time that the string represents in Kabul time" do
          expect(Time.zone.parse("2014-03-16T23:32:11+06:00").iso8601).to eq("2014-03-16T22:02:11+04:30")
        end
      end

      describe "#now" do
        it "returns what the time is now in the configured time zone" do
          expect(Time.zone.now.iso8601).to eq("2014-03-15T22:16:11+04:30")
        end
      end

      describe "#today" do
        it "returns what the date is now in the configured time zone" do
          expect(Time.zone.today.iso8601).to eq("2014-03-15")
        end
      end
    end

    context "time zone is Samoa" do
      before { Time.zone = "Pacific/Apia" }

      describe "data source" do
        it "returns the correct utc_offset for Samoa" do
          expect(Time.zone.utc_offset / 3600).to eq(13)
        end
      end

      after { Time.zone = "Kabul" }
    end
  end

  describe ActiveSupport::Duration do
    describe "#ago" do
      it "returns the time what the time was 2 minutes ago in Kabul time" do
        expect(2.minutes.ago.iso8601).to eq("2014-03-15T22:14:11+04:30")
      end
    end
  end

  describe Date do
    describe "#in_time_zone" do
      it "returns the date as a time in the current time zone" do
        expect(Date.current.in_time_zone.iso8601).to eq("2014-03-15T00:00:00+04:30")
      end

      it "can return the date as a time in in a given time zone" do
        expect(Date.current.in_time_zone("Adelaide").iso8601).to eq("2014-03-15T00:00:00+10:30")
      end

      it "returns the correct date in a configured time zone which is before UTC", frozen: "2015-08-17T22:00:00Z" do
        expect(Date.current.to_s).to eq("2015-08-18")
      end

      it "returns the correct date in a time zone which is before UTC", frozen: "2015-08-17T22:00:00Z" do
        expect(Date.current.in_time_zone("Australia/Sydney").to_date.to_s).to eq("2015-08-18")
      end
    end
  end

  describe Time do
    describe ".strptime" do
      it "parses the given time string using the supplied format" do
        parsed = Time.strptime("2014-03-16T23:32:11+06:00", "%Y-%m-%dT%H:%M:%S%z")
        expect(parsed.in_time_zone.iso8601).to eq("2014-03-16T22:02:11+04:30")
      end

      it "raises error if passed in string doesn't follow the format" do
        expect { Time.strptime("201403-16T23:32:11+06:00", "%Y-%m-%dT%H:%M:%S%z") }.to raise_error(ArgumentError)
      end
    end

    describe ".zone" do
      it "returns the currently configured time zone" do
        expect(Time.zone.name).to eq("Kabul")
      end
    end

    describe ".use_zone" do
      it "changes the default time zone within the block" do
        Time.use_zone("Adelaide") do
          expect(Time.zone.name).to eq("Adelaide")
        end
      end
    end

    describe "#current" do
      it "returns what the time is now in the configured time zone" do
        expect(Time.current.iso8601).to eq("2014-03-15T22:16:11+04:30")
      end
    end

    describe "#utc" do
      it "returns the time in the UTC time zone" do
        expect(Time.current.utc.iso8601).to eq("2014-03-15T17:46:11Z")
      end
    end

    describe "#strptime" do
      it "doesn't exist" do
        expect { Time.current.strptime }.to raise_error(NoMethodError)
      end
    end
  end
end
