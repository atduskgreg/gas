require 'net/https'
require 'uri'
require 'cgi'

class GAS # GoogleAuthSub
  ASS_URL = "https://www.google.com/accounts/AuthSubSessionToken"
  
  def self.request_url(opts={})
    raise ArgumentError, "Must include a 'next' url (i.e. your url to which you wish the user to be redirected) and a 'scope' url (i.e. the Google service url)" unless opts[:next] && opts[:scope]
    
    "https://www.google.com/accounts/AuthSubRequest?next=#{CGI.escape opts[:next]}&scope=#{CGI.escape opts[:scope]}&session=#{opts[:session] ? 1 : 0}&secure=#{opts[:secure] ? 1 : 0}"
  end
  
  # Exchange an AuthSubRequest token for an AuthSubSession token 
  # (see: http://code.google.com/apis/blogger/developers_guide_protocol.html#Auth for details on obtaining an AuthSubRequest token in the first place)
  # (token must have been requested with the session flag thrown in the original AuthSub request)
  # If successful, create_session_token will return an AuthSubSession token string (see: http://code.google.com/apis/accounts/AuthForWebApps.html#AuthSubSessionToken); 
  # otherwise, create_session_token will return false.
  # Creating tokens from a signed request is a whole other bag of worms I have not yet stomped on: http://code.google.com/apis/accounts/docs/AuthForWebApps.html#signingrequests
  #
  def self.create_session_token(token, secure=false)
    response = securely_get ASS_URL, {"Authorization" => 'AuthSub token="'+token+'"'}
    if response.code == "200"
      response.body.gsub("\n", '').split("Token=").last    
    else
      return false
    end
  end
  
  # helper methods for sending the necessary secure requests (someone explain to me why this is not already in Net::HTTP!?!)
  
  def self.securely_get(url, headers=nil)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.start { http.get2(uri.path, headers) } 
  end
  
  def self.securely_post(url, data=nil, user_headers=nil)
    headers = {"Content-Length" => (data ? data.length : 0 ).to_s}.merge(user_headers)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.start { http.post2(uri.path, data, headers) }  
  end
end
