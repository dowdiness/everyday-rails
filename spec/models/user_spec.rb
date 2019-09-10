require 'rails_helper'

RSpec.describe User, type: :model do
  # 有効なファクトリを持つこと
  it "has a valid factory" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  # 名がなければ無効な状態であること
  it { is_expected.to validate_presence_of :first_name }
  # 姓がなければ無効な状態であること
  it { is_expected.to validate_presence_of :last_name }
  # メールアドレスがなければ無効な状態であること
  it { is_expected.to validate_presence_of :email }
  # 重複したメールアドレスなら無効な状態であること
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  # ユーザーのフルネームを文字列として返すこと
  it "returns a user's full name as a string" do
    user = FactoryBot.build(:user, first_name: "John", last_name: "Doe",)
    expect(user.name).to eq "John Doe"
  end

  it "sends a welcome email on account creation" do
    allow(UserMailer).to receive_message_chain(:welcome_email, :deliver_later)
    user = FactoryBot.create(:user)
    expect(UserMailer).to have_received(:welcome_email).with(user)
  end

  # ジオコーディングを実行すること
  it "performs geocoding", vcr: true do
    user = FactoryBot.create(:user, last_sign_in_ip: "161.195.207.20")
    expect {
      user.geocode
    }.to change(user, :location).
      from(nil).
      to("Philadelphia, Pennsylvania, US")
  end
end
