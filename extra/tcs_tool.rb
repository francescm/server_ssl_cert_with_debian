require 'openssl'
require 'time'

#KEYSIZE = 4096
KEYSIZE = 2048

class TCSUtil
  def initialize(name, key_size = KEYSIZE)
    @name = name
    @key_size = key_size
  end

  def create_key
    puts "creating key for #{@name}"
    @key = OpenSSL::PKey::RSA.new @key_size
    keyfile = "keys/#{@name}.key"
    File.write keyfile, @key.to_pem
    File.chmod(0400, keyfile)
  end

  def create_csr
    csr = OpenSSL::X509::Request.new
    csr.version = 0
    subject = OpenSSL::X509::Name.parse "CN=#{@name}"
    puts subject
    csr.subject = subject
    csr.public_key = @key.public_key
    csr.sign @key, OpenSSL::Digest::SHA1.new
    File.write "csr/#{@name}.csr", csr.to_pem
  end
end

raise RuntimeError, "Usage: ruby #{__FILE__} dn [..other_dn]" if ARGV.empty?

ARGV.each do |cert|
  util = TCSUtil.new cert
  util.create_key
  util.create_csr
end

