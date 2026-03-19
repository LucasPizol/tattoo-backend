class Api::ContractsController < Api::ApplicationController
  def index
    authorize(Contract, :index?)

    @contracts = Contract.joins(:user)
                         .where(users: { company_id: current_company.id })
                         .includes(:user)
                         .order(created_at: :desc)
  end

  def show
    authorize(Contract, :show?)

    @contract = Contract.joins(:user)
                        .where(users: { company_id: current_company.id })
                        .find(params[:id])
  end

  def pending
    contract = current_user.contracts.pending.order(created_at: :desc).first

    if contract
      render json: {
        contract: {
          id: contract.id,
          content: contract.content,
          version: contract.version,
          status: contract.status,
          created_at: contract.created_at
        }
      }, status: :ok
    else
      render json: { contract: nil }, status: :ok
    end
  end

  def sign
    contract = current_user.contracts.pending.find(params[:id])

    signature_data = params[:signature]
    return render json: { message: "Assinatura é obrigatória" }, status: :unprocessable_entity if signature_data.blank?

    base64_data = signature_data.sub(/\Adata:image\/\w+;base64,/, "")
    binary_data = Base64.decode64(base64_data)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(binary_data),
      filename: "signature_#{contract.id}_#{Time.current.to_i}.png",
      content_type: "image/png"
    )

    contract.signature.attach(blob)
    contract.update!(
      status: :signed,
      signed_at: Time.current,
      signer_ip: request.remote_ip,
      signer_user_agent: request.user_agent
    )

    render json: { message: "Contrato assinado com sucesso" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { message: "Contrato não encontrado" }, status: :not_found
  end
end
