# name: Active Directory
# about: Authenticate on Discourse with your Active Directory.
# version: 0.1.0
# author: Chris Wells <cwells@thegdl.org>

#gem 'rack', '1.6.4'
#gem 'hashie', '3.4.2'
gem 'rubyntlm', '0.5.1'
#gem 'kiro-ruby-sasl', '0.0.4.0'
gem 'net-ldap', '0.11'
gem 'omniauth', '1.2.2'
gem 'kiro-ruby-sasl', '0.0.4.0'
gem 'kiro-omniauth-ldap', '1.0.6'


class ADAuthenticator < ::Auth::Authenticator

	def name
		'active_directory'
	end
	
	def after_authenticate(auth_token)
		result = Auth::Result.new
		
		authad_uid = auth_token[:uid]
        	data = auth_token[:info]
		result.email = email = data[:email]
		result.name = name = data[:name]

		result.extra_data = {
			uid: authad_uid,
			provider: auth_token[:provider],
			name: name,
			email: email,
		}
		
		result
	end
	
	def after_create_account(user, auth)
		data = auth[:extra_data]
	end
	
	def register_middleware(omniauth)
		omniauth.provider :ldap,
		  :host => 'DC',
						  :port => 389,
						  :method => :plain,
						  :base => 'BASE_DN',
						  :uid => 'sAMAccountName',
						  :bind_dn => 'BIND_DN',
						  :password => 'BIND_PASS'
						#  :host => PluginSettings[:active_directory].authad_domain_controller,
						 # :port => 389,
						  #:method => :plain,
						  #:base =>  Discourse.PluginSettings[:active_directory].authad_base_dn,
#						  #:uid => '',
						  #:bind_dn => Discourse.PluginSettings[:active_directory].authad_bind_dn,
						  #:password => Discourse.PluginSettings[:active_directory].authad_bind_pass
	end
end

auth_provider :title => 'with Active Directory',
	:message => 'Log in with Active Directory',
	:frame_width => 920,
	:frame_height => 800,
	:authenticator => ADAuthenticator.new
	
register_css <<CSS

.btn-social.windows {
	background: #0052A4;
}

.btn-social.windows:before {
	content: "N";
}

CSS
