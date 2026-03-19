class User::UnauthorizedException < StandardError
  def initialize(message = "Usuário sem privilégios para acessar este recurso")
    super(message)
  end
end
