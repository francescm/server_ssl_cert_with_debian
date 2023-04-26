require 'openssl'
require 'time'

# courtesy of: https://alexpeattie.com/blog/signing-a-csr-with-ecdsa-in-ruby
# thanks to https://gist.github.com/aspyatkin/23c336b811aac211040f as well

class TCSUtil
  OpenSSL::PKey::EC.send(:alias_method, :private?, :private_key?)

  def initialize(name, san)
    @name = name
    #curve_name = "secp384r1"
    #@curve_name = "secp521r1"
    @curve_name = "prime256v1"
    @san = san
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
    subject = OpenSSL::X509::Name.new [
  	  ['CN', @name],
	  ['C', "IT"],
     ] 
    #subject = OpenSSL::X509::Name.parse "CN=#{@name}"
    puts subject
    csr.subject = subject
    csr.public_key = @ec_public

# prepare SAN extension
    san_list = @san.map { |domain| "DNS:#{domain}" }
    extensions = [
      OpenSSL::X509::ExtensionFactory.new.create_extension('subjectAltName', san_list.join(','))
    ]

    # add SAN extension to the CSR
    attribute_values = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(extensions)]
    [
      OpenSSL::X509::Attribute.new('extReq', attribute_values),
      OpenSSL::X509::Attribute.new('msExtReq', attribute_values)
    ].each do |attribute|
      csr.add_attribute attribute
    end

    csr.sign @key, OpenSSL::Digest::SHA256.new
    File.write "csr/#{@name}.csr", csr.to_pem
  end
end

raise RuntimeError, "Usage: ruby #{__FILE__} dn [...SAN extensions]" if ARGV.empty?

dn = ARGV.first
san = ARGV[1..]

util = TCSUtil.new(dn, san)
util.create_key
util.create_csr

