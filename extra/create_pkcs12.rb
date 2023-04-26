#encoding: utf-8

require 'openssl'

class Pkcs12
  def initialize(pass, name, key, cert)
    @pass = pass
    @name = name
    raise RuntimeError, "key file #{key} not found" unless File.exists? key
    @key = OpenSSL::PKey.read File.read(key)
    raise RuntimeError, "cert file #{cert} not found" unless File.exists? cert
    @cert = OpenSSL::X509::Certificate.new File.read cert
  end

  def create
    chain = create_chain
    pkcs12 = OpenSSL::PKCS12.create(@pass, @name, @key, @cert, chain)
    derfile = "pkcs12/#{@name}.pkcs12"
    File.write derfile, pkcs12.to_der
#    terena_3 =  OpenSSL::X509::Certificate.new File.read("ca/TERENA_SSL_CA_3.pem")
#    File.open(derfile, "a") do |f|
#            f.write terena_3.to_der
#    end
  end

  private
  def create_chain
    chain = []
    ca = %w{geant_ov_ecc_ca_4.pem usertrust_ecc.pem geant_ov_rsa_ca_4.pem  usertrust_rsa_certification_authority.cer aaa_certificate_services.cer}
    #ca = %w{TERENA_SSL_CA_3.pem DigiCert_Assured_ID_Root_CA.pem}
    #ca = %w{TERENA_SSL_High_Assurance_CA_3.pem DigiCert_High_Assurance_EV_Root_CA.pem}
    ca.each do |file|
      raw = File.read "ca/#{file}"
      chain << OpenSSL::X509::Certificate.new(raw)
    end
    chain
  end
end

raise RuntimeError, "Usage: ruby #{__FILE__} pass name key cert" unless ARGV.size.eql? 4
Pkcs12.new(*ARGV).create

