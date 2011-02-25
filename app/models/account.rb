class Account < ActiveRecord::Base

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true, :uniqueness => true
  validates :page_url, :presence => true, :format => /(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  validate :has_at_least_one_category
  validate :has_no_more_than_two_categories

  attr_accessible :first_name, :last_name, :email, :page_url, :category_ids

  before_create :generate_token, :send_confirmation_mail

  has_and_belongs_to_many :categories

  scope :confirmed, where('accounts.confirmed_at IS NOT NULL')

  def self.search(term)
    if term =~ /^(.+) (\S+)$/ # two names
      where(['first_name LIKE ? AND last_name LIKE ?', "#{$1}%", "#{$2}%"])
    else # one name; match on first name OR last name
      like_term = "#{term.rstrip}%"
      where(['first_name LIKE ? OR last_name LIKE ?', like_term, like_term])
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest(rand(36**32).to_s(36)) #quick & dirty psudo random token
    self.token_expires_at = Time.now + 2.hours
  end

  def generate_token!
    self.generate_token
    self.save
  end

  def send_confirmation_mail
    AccountConfirmation.confirm_account(self).deliver
  end

  def confirmed?
    !!self.confirmed_at
  end

  def expired?
    self.token_expires_at.nil? || self.token_expires_at < Time.now
  end

  def confirm!
    self.confirmed_at = Time.now
    self.token_expires_at = Time.now + 2.hours
    self.save
  end

  private

  def has_at_least_one_category
    errors[:categories] << "must choose at least one category" if categories.length < 1
  end

  def has_no_more_than_two_categories
    errors[:categories] << "cannot choose more than two categories" if categories.length > 2
  end

  class << self

    def confirm_by_token(token)
      if account = Account.find_by_token(token)
        account.confirm!
        return account
      else
        return false
      end
    end

  end

end
