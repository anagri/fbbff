# Understands the paginated comments as returned by facebook koala api

class PaginatedComments
  def initialize(api, response)
    @api = api
    @comments = response
    @current_index = 0
  end

  def each
    while has_next?
      yield get_next
    end
  end

  private
  def has_next?
    if get_data.size <= @current_index
      @comments = get_next_page
      @current_index = 0
    end
    get_data.size != 0
  end

  def get_next
    get_data[@current_index].tap {
      @current_index+=1
    }
  end

  def get_data
    @comments.is_a?(Hash) ? @comments['data'] : @comments
  end

  def get_next_page
    if @comments.respond_to?(:next_page)
      @comments.next_page
    elsif @comments['paging'] && @comments['paging']['next']
      begin
        base, args = Koala::Facebook::API::GraphCollection.parse_page_url(@comments['paging']['next'])
        @api.get_page([base, args])
      rescue
        []
      end
    else
      []
    end
  end
end