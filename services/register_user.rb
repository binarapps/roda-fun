require 'yaml'

class UnauthorizedUser < Exception; end

class RegisterUser

  def initialize(params)
    @email = params['email']
    @password = params['password']
    @password_confirmation = params['password_confirmation']
    @github_login = params['github_login']
  end

  def call
    # Uncomment this line if you want to have user filtration
    # authorize_specific_users if production?
    User.create(email: @email,
                password: @password,
                password_confirmation: @password_confirmation,
                github_login: @github_login)
  end

  private
  def authorize_specific_users
    yml = YAML.load_file('configurations/authorized_users.yml')
    raise UnauthorizedUser unless yml[@email]
  end
end
