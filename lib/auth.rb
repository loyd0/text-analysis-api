require 'jwt'

class Auth
  ALGORITHM  = "HS256"

def self.encode(payload, expiry=(24*7).hours.from_now)
  payload[:exp ] = expiry.to_i
  JWT.encode(payload, auth_secret, ALGORITHM)
end

def self.decode(token, leeway=0)
  decoded = JWT.decode(token, auth_secret, true, {leeway: leeway, algorithm: ALGORITHM})
  #Leeway the amount of time you wait before the it errors. By default its unlimited time.
  HashWithIndifferentAccess.new(decoded[0])
end

def self.auth_secret
  ENV["AUTH_SECRET"]
end

end
