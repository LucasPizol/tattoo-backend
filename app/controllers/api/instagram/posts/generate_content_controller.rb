class Api::Instagram::Posts::GenerateContentController < Api::ApplicationController
  def create
    caption = instagram_post_params[:caption] || instagram_post&.caption

    instagram_post.contents.attach(instagram_post_params[:contents]) if instagram_post.present?

    response = Ai::Google.new(user: @current_user).generate_text(
      prompt: "Você é um assistente útil que gera conteúdo para um post do Instagram. O post é sobre #{caption}. Gere uma legenda para o post. Siga o conteúdo apresentado. Devolva apenas a legenda, sem nenhum outro texto.",
      images: instagram_post.present? ? instagram_post.contents : instagram_post_params[:contents]
    )

    render json: { content: response }, status: :ok
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  private

  def instagram_post_params
    params.fetch(:instagram_post, {}).permit(:caption, contents: [])
  end

  def instagram_post
    @instagram_post ||= params[:post_id] != 0 ? @current_company.instagram_posts.find_by(id: params[:post_id]) : nil
  end
end
