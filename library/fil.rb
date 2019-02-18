require 'digest'

module Encryption
  def encrypt_password
    Digest::SHA2.hexdigest(password)
  end
end

class Person

  include Encryption

  attr_accessor :password
  def initialize(password)
    self.password = password
  end

  def encrypted_password
    encrypt_password
  end
end

person = Person.new("super secret")
puts person.encrypted_password
