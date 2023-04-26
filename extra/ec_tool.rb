require 'openssl'
require 'time'

# courtesy of: https://alexpeattie.com/blog/signing-a-csr-with-ecdsa-in-ruby

class TCSUtil
  OpenSSL::PKey::EC.send(:alias_method, :private?, :private_key?)

  def initialize(name)
    @name = name
    #curve_name = "secp384r1"
    #@curve_name = "secp521r1"
    @curve_name = "prime256v1"
  end

  def create_key
    puts "creating key for #{@name}"
    @key = OpenSSL::PKey::EC.new @curve_name
    @ec_public = OpenSSL::PKey::EC.new @curve_name
    @key.generate_key
    @ec_public.public_key = @key.public_key
    keyfile = "keys/#{@name}.key"
    File.write keyfile, @key.to_pem
    File.chmod(0640, keyfile)
  end

  def create_csr
    csr = OpenSSL::X509::Request.new
    csr.version = 0
    subject = OpenSSL::X509::Name.parse "CN=#{@name}"
    puts subject
    csr.subject = subject
    csr.public_key = @ec_public
    csr.sign @key, OpenSSL::Digest::SHA256.new
    File.write "csr/#{@name}.csr", csr.to_pem
  end
end

raise RuntimeError, "Usage: ruby #{__FILE__} dn [..other_dn]" if ARGV.empty?

ARGV.each do |cert|
  util = TCSUtil.new cert
  util.create_key
  util.create_csr
end

