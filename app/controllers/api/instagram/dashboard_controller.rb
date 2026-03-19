class Api::Instagram::DashboardController < Api::ApplicationController
  def show
    posts = @current_company.instagram_posts.published.where.not(published_at: nil)
    comments = Instagram::Comment.where(instagram_post_id: @current_company.instagram_posts.select(:id))

    published_at_local = "(published_at AT TIME ZONE 'UTC') AT TIME ZONE 'America/Sao_Paulo'"
    created_at_local = "(instagram_comments.created_at AT TIME ZONE 'UTC') AT TIME ZONE 'America/Sao_Paulo'"

    @by_hour = posts
      .select("EXTRACT(HOUR FROM #{published_at_local})::int as hour, SUM(ig_like_count) as total_likes, SUM(ig_comments_count) as total_comments, COUNT(*) as post_count")
      .group("EXTRACT(HOUR FROM #{published_at_local})::int").order("hour")

    @by_weekday = posts
      .select("EXTRACT(DOW FROM #{published_at_local})::int as weekday, SUM(ig_like_count) as total_likes, SUM(ig_comments_count) as total_comments, COUNT(*) as post_count")
      .group("EXTRACT(DOW FROM #{published_at_local})::int").order("weekday")

    @by_month = posts
      .select("TO_CHAR(#{published_at_local}, 'YYYY-MM') as month, SUM(ig_like_count) as total_likes, SUM(ig_comments_count) as total_comments, COUNT(*) as post_count")
      .group("TO_CHAR(#{published_at_local}, 'YYYY-MM')").order("month")

    @comments_by_hour = comments
      .select("EXTRACT(HOUR FROM #{created_at_local})::int as hour, COUNT(*) as comment_count")
      .group("EXTRACT(HOUR FROM #{created_at_local})::int")
      .order("hour")

    @top_commenters = comments
      .select("username, COUNT(*) as comment_count")
      .group("username")
      .order("comment_count DESC")
      .limit(20)
  end
end
