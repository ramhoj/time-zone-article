# frozen_string_literal: true

describe UsersController, :truncation, frozen: "2014-03-15T23:31:11+05:45" do
  let(:user) { User.create!(time_zone: "Hawaii") }

  def get_time_zone_name(user)
    get(user_path(user))
    JSON.parse(response.body)["time_zone"]["name"]
  end

  describe "GET users/:id" do
    it "gets the correct time zone" do
      expect(get_time_zone_name(user)).to eq("Hawaii")
    end

    context "when multiplie users accessing concurrently" do
      # Note: I have not been able to make this fail even when
      # setting and restoring Time.zone in the action instead of
      # using Time.use_zone with a block as an around action.
      it "gets the correct time zone" do
        path = Rails.root.join("spec", "fixtures", "time_zones.yml").to_s
        content = File.read(path)
        time_zone_names = YAML.safe_load(content, [Symbol])[:time_zones]

        time_zone_names.sample(13).each do |time_zone_name|
          expect(
            Thread.new { get_time_zone_name(User.create!(time_zone: time_zone_name)) }.value
          ).to eq(time_zone_name)
        end
      end
    end
  end

  describe "GET /users/:id/without_individial_time_zone" do
    it "gets the correct time zone" do
      get without_individial_time_zone_user_path(user)
      time_zone_name = JSON.parse(response.body)["time_zone"]["name"]

      expect(time_zone_name).to eq("Kabul")
    end
  end
end
