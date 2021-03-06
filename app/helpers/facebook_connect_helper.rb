module FacebookConnectHelper

  FACEBOOK_CONNECT_COOKIE_PREFIX = "fbsr_"
  FACEBOOK_CONNECT_SESSION_ID    = :fb_connect_user2

  def check_facebook_connect_session
    if fb_connect_session.nil? # not exists

      # Try to load facebook connect cookies
      # Create new facebook session and store on session
      fb_session = build_fb_session

      # If cookies are found
      if fb_session && fb_session.user

        # Create new facebook session and store on session
        fb_uid = fb_session.user.uid

        # Ensure associated user is already in database
        # otherwise create new user and assign on session

        if !User.exists?(:facebook_uid => fb_uid)
          user = User.register_by_facebook_account(fb_session, fb_uid)
          user.log_it!(request.env["HTTP_X_FORWARDED_FOR"] || request.remote_addr)
        else
          user = User.update_facebook_session(fb_uid, fb_session)
          user.log_it!(request.env["HTTP_X_FORWARDED_FOR"] || request.remote_addr)
        end

        self.current_user = User.find_by_facebook_uid(fb_uid)
        create_fb_connect_session(fb_session)
        flash[:notice] = 'You are connected through facebook'
      end
    end
  end

  def fb_cookies_key
    "#{FACEBOOK_CONNECT_COOKIE_PREFIX}#{@topic.fb_connect_key.blank? ? Facebooker.api_key : @topic.fb_connect_key}"
  end

  def fb_cookies
    cookies[fb_cookies_key]
  end

  def restaurant_review_title(p_review, shared = false)
    if !shared
      if p_review.loved?
        '&hearts; Loved and reviewed this place!'
      elsif p_review.hated?
        'Hated and reviewed this place! '
      elsif p_review.wanna_go?
        'Wanna go to '
      end
    else
      'Shared review from'
    end
  end

  def restaurant_review_stat(p_review_or_restaurant)
    restaurant = nil

    if p_review_or_restaurant.is_a?(Review)
      restaurant = p_review_or_restaurant.any
    elsif p_review_or_restaurant.is_a?(Restaurant)
      restaurant = p_review_or_restaurant
    end

    total_reviews_count = restaurant.reviews.count
    loved_count         = restaurant.reviews.loved.count
    "#{restaurant.checkins_count.to_i} check ins, #{total_reviews_count} review#{total_reviews_count > 1 ? 's' : ''}, #{loved_count} love#{total_reviews_count > 1 ? 's' : ''}, #{restaurant.rating_out_of(5).round} out of 5 ratings!"
  end

  def fb_connect_key
    @topic && @topic.fb_connect_key.present? ?
        @topic.fb_connect_key :
        Facebooker.api_key
  end

  private
    def fb_connect_session
      session[FACEBOOK_CONNECT_SESSION_ID]
    end

    def build_fb_session
      parsed = { }

      if params[:fskey] && params[:fuid]
        parsed = {
            'session_key'  => params[:fskey],
            'uid'          => params[:fuid],
            'expires'      => params[:fexpires],
            'secret'       => params[:fsecret],
            'access_token' => params[:fat]
        }
      end

      if parsed && !parsed.empty?
        @facebook_session = new_facebook_session
        @facebook_session.secure_with!(
            parsed['session_key'],
            parsed['uid'],
            parsed['expires'],
            parsed['secret'])
        @facebook_session.auth_token = parsed['access_token']
        @facebook_session
      else
        nil
      end
    end

    def create_fb_connect_session(fb_session)
      session[FACEBOOK_CONNECT_SESSION_ID] = fb_session
    end

    def parse_fb_cookie(fb_cookie)
      map       = { }
      fb_cookie = fb_cookie.gsub(/"/, '')
      fb_cookie.split('&').collect do |part|
        parts = part.split('=');
        map[parts.first] = parts.last
      end
      map['expires'] = Time.at(map['expires'].to_i)
      map
    end
end
