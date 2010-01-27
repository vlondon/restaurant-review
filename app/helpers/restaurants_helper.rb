module RestaurantsHelper

  def render_most_lovable_places(p_config, p_limit = 5)
    render :partial => 'restaurants/parts/lovable_places', :locals => {
        :more_link => most_loved_places_url,
        :config => p_config,
        :restaurants => Restaurant.most_loved(@topic, p_limit)}
  end

  def render_restaurant_review_stats(p_restaurant, p_short = true)
    reviews = p_restaurant.reviews
    if !reviews.empty?
      total_reviews_count = p_restaurant.reviews.count
      loved_count = p_restaurant.reviews.loved.count
      loved_percentage = (100 / total_reviews_count) * loved_count

      variables = {
          :total_reviews_count => total_reviews_count,
          :loved_count => loved_count,
          :loved_percentage => loved_percentage
      }

      render :partial => 'restaurants/parts/review_stats', :locals => variables
    end
  end

  def render_recently_added_places(p_config, p_limit = 10)
    render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
        :config => p_config,
        :more_link => recently_reviewed_places_url,
        :reviews => Review.by_topic(@topic.id).recent.all(:include => [:restaurant], :limit => p_limit)}
  end

  def render_recently_added_pictures(p_limit = 5)
    render :partial => 'restaurants/parts/recently_added_pictures', :locals => {
        :title => 'Recently added pictures!',
        :more_link => recently_reviewed_places_url,
        :restaurants => Restaurant.recently_added_pictures(p_limit)}
  end

  def render_who_wanna_go_there(p_restaurant, p_limit = 5)
    wanna_go_reviews = p_restaurant.reviews.by_topic(@topic.id).wanna_go.all(:limit => p_limit, :include => [:user])
    render :partial => 'restaurants/parts/who_wanna_go_there', :locals => {
        :title => 'Who wanna visit here!',
        :reviews => wanna_go_reviews,
        :more_link => who_wanna_go_place_url(:id => p_restaurant.id, :name => p_restaurant.name.parameterize.to_s)
    }
  end

  def render_tagcloud(p_config)
    bind_column = p_config['bind_column'].to_sym
    tags = Restaurant.find_tags_of(bind_column, @topic)
    render :partial => 'restaurants/parts/tagcloud', :locals => {
        :config => p_config,
        :tags => tags,
        :column => bind_column
    }
  end
end
