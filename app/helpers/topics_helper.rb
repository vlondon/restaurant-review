module TopicsHelper

  def render_topic_box(p_options)
    topics = Topic.all
    render :partial => 'topics/parts/all_topics', :locals => {:topics => topics}
  end

end