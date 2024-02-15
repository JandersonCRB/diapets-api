require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = create(:user,
                  first_name: "John",
                  last_name: "Doe",
                  email: "johndoe@example.com",
                  password: "password")
    expect(user).to be_valid
  end

  it "is not valid without a first name" do
    user = build(:user,
                 first_name: nil,
                 last_name: "Doe",
                 email: "johndoe@example.com",
                 password: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without a last name" do
    user = build(:user,
                 first_name: "John",
                 last_name: nil,
                 email: "johndoe@example.com",
                 password: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = build(:user, first_name: "John", last_name: "Doe", email: nil, password: "password")

    expect(user).to_not be_valid
  end

  it "is not valid without a password" do
    user = build(:user,
                 first_name: "John",
                 last_name: "Doe",
                 email: "johndoe@example.com",
                 password: nil)

    expect(user).to_not be_valid
  end

  it "is not valid without a unique email" do
    create(:user,
           first_name: "John",
           last_name: "Doe",
           email: "johndoe@example.com",
           password: "password")
    user = build(:user,
                 first_name: "John",
                 last_name: "Doe",
                 email: "johndoe@example.com",
                 password: "password")

    expect(user).to_not be_valid
  end

  describe "Password encryptions" do
    it "encrypts the password" do
      user = create(:user,
             first_name: "John",
             last_name: "Doe",
             email: "johndoe@example.com",
             password: "password")

      expect(user.password_digest).to_not eq("password")
    end

    it "authenticates the password" do
      user = create(:user,
                    first_name: "John",
                    last_name: "Doe",
                    email: "johndoe@example.com",
                    password: "password")

      expect(user.authenticate_password("password")).to eq(user)
    end

    it "does not authenticate the password" do
      user = create(:user,
                    first_name: "John",
                    last_name: "Doe",
                    email: "johndoe@example.com",
                    password: "password")

      expect(user.authenticate_password("wrongpassword")).to eq(false)
    end

    it "does not authenticate the password when the password is nil" do
      user = create(:user,
                    first_name: "John",
                    last_name: "Doe",
                    email: "johndoe@example.com",
                    password: "password")

      expect(user.authenticate_password(nil)).to eq(false)
    end

    it "does not authenticate the password when the password is empty" do
      user = User.new(
        first_name: "John",
        last_name: "Doe",
        email: "johndoe@example.com",
        password: "password"
      )

      user.save

      expect(user.authenticate_password("")).to eq(false)
    end

    it "does not authenticate the password when the password is not present" do
      user = create(:user,
                    first_name: "John",
                    last_name: "Doe",
                    email: "johndoe@example.com",
                    password: "password")

      expect(user.authenticate_password(nil)).to eq(false)
    end
  end
end
