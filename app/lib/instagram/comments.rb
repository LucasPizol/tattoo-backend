# frozen_string_literal: true

module Instagram::Comments
  def list_comments(media_id:, account:, after: nil)
    url = "#{graph_url}/#{media_id}/comments?fields=id,text,username,timestamp"
    url += "&after=#{CGI.escape(after)}" if after.present?

    response = http_client(token: account.ig_access_token).get(url)

    if response.success?
      response.body
    else
      raise "Failed to list comments: #{response.body}"
    end
  end

  def list_all_comments(media_id:, account:, &block)
    all_comments = []
    after = nil

    loop do
      result = list_comments(media_id: media_id, account: account, after: after)
      data = result["data"] || []
      all_comments.concat(data)

      cursors = result.dig("paging", "cursors")
      after = cursors&.dig("after")
      break if after.blank?

      block.call(result) if block_given?
    end

    all_comments
  end
end
