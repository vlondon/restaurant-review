# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require 'user_activity_monitoring_helper'

class ApplicationController < ActionController::Base

  include UserActivityMonitoringService
  policy :keep_away_ip_banned_visitors

  include ExceptionNotification::ExceptionNotifiable

  if !['test', 'staging', 'development'].include?(Rails.env)
    alias :rescue_action_locally :rescue_action_in_public
  end

  rescue_from ActionController::InvalidAuthenticityToken, :with => :bad_auth_token

  # Be sure to include AuthenticationSystem in Application Controller instead
  include CacheHelper
  include AuthenticatedSystem
  include UsersHelper
  include ApplicationHelper
  include UrlOverrideHelper
  include FacebookConnectHelper
  include MobileHelper
  include StringHelper
  include LocaleHelper
  include PremiumHelper
  include PremiumTemplatesHelper
  include SearchHelper
  include MultidomainCookieHelper
  include PartialViewHelperHelper
  include TemplateServiceHelper
  include StuffEventsHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'fresh'

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :fb_sig_friends, :password

  before_filter :set_cookie_domain
  before_filter :detect_premium_site_or_topic_or_forward_to_default_one
  before_filter :check_facebook_connect_session
  before_filter :detect_mobile_view
  before_filter :detect_locale
  before_filter :detect_fake_email
  before_filter :determine_rotatable_background_image

  protected

    def bad_auth_token
      logger.warn('Caught invalid authenticity request')
      flash[:notice] = 'Invalid authenticity token, please try again'
      redirect_to request.referer.present? ? request.referer : root_url
    end

    def default_url_options(options = {})
      # Force for url locale
      options[:l] = I18n.locale if !options.keys.include?(:l)

      determine_host! options

      # Force Content Format
      if defined?(params) && options[:format].nil? && params[:format]
        if !params[:format].to_s.match(/^ajax|asset/)
          options[:format] = params[:format]
        end
      end

      options
    end

    def determine_host! (options)
      # If ajax is request host, forcefully set different
      # topic sub domain as url host
      if request && !options.include?(:subdomain) && !options.include?(:host)
        host_parts = request.host.split('.')

        if (host_parts.first || '').match(/^ajax\d+$/)
          if @subdomain_routing_stop
            options[:subdomain] = 'www'
          else
            options[:subdomain] = @topic ? @topic.subdomain : nil
          end
        elsif @topic.user_subdomain?
          options[:subdomain] = 'www'
        elsif @topic
          options[:host] = @topic.public_host
        end
      end
    end

    def if_permits? (object)
      if object && object.author?(current_user)
        yield
      else
        flash[:notice] = 'You are not authorized!'
        redirect_to root_url
      end
    end

    def detect_fake_email
      if logged_in?
        if current_user.fake_email?
          if request.url != edit_user_url(current_user) &&
              request.url != user_url(current_user) &&
              request.url != logout_url &&
              request.url != fb_logout_url
            flash[:notice] = 'Please enter your email address'
            session[:fake_email] = true
            redirect_to edit_user_url(current_user)
          end
        end
      end
    end

    @@background_images = []

    #
    # Determine rotatable background image by current time
    # ie. 0 means default image
    #     1-12 means 1 AM to 12 PM
    #     13-18 means 13 PM to 18 PM
    # Mention *:load_bg* for loading background image
    def determine_rotatable_background_image
      if @@background_images.empty? || params[:load_bg]
        @@background_images = load_background_images
      end

      @background_image = @@background_images["hour_#{Time.now.hour}"] || @@background_images[:default]
    end

    def load_background_images
      hourly_image_files = {}

      Dir.glob(File.join(RAILS_ROOT, 'public', 'bg-pictures', '*.jpg')).each do |path|
        image_file = path.gsub(/#{File.join(RAILS_ROOT, 'public')}/, '')
        time_parts = image_file.split('/').last.split('.').first.split('-')

        # Determine default image
        if time_parts.length == 1 && time_parts.first == '0'
          hourly_image_files[:default] = image_file

        # Determine time range
        elsif time_parts.length == 2
          if time_parts.first.to_i < time_parts.last.to_i
            (time_parts.first.to_i..time_parts.last.to_i).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end
          else
            (time_parts.first.to_i..24).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end

            (0..time_parts.last.to_i).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end
          end
        end
      end

      hourly_image_files
    end

    def authorize
      if !current_user || !current_user.admin?
        flash[:notice] = 'You are not authorized to access this url.'
        redirect_to root_url
      end
    end

    def notify(type, redirect, options = {})
      case type
        when :success
          flash[:success] = options[:success_message] || 'Successfully completed!'
          redirect_to redirect

        when :failure
          flash[:notice] = options[:failure_message] || 'Failed to complete!'
          if redirect.is_a?(Symbol) && redirect != :back
            render :action => redirect
          else
            redirect_to redirect
          end
      end
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

    def restaurant_review_stat(p_review)
      restaurant = nil

      if p_review.is_a?(Review)
        restaurant = p_review.any
      elsif p_review.is_a?(Restaurant)
        restaurant = p_review
      end

      total_reviews_count = restaurant.reviews.count
      loved_count = restaurant.reviews.loved.count
      "#{restaurant.checkins_count.to_i} check ins, #{total_reviews_count} review#{total_reviews_count > 1 ? 's' : ''}, #{loved_count} love#{total_reviews_count > 1 ? 's' : ''}, #{restaurant.rating_out_of(5).round} out of 5 ratings!"
    end

    def remove_html_entities(p_str)
      (p_str || '').gsub(/<[\/\w\d\s="\/\/\.:'@#;\-]+>/, '')
    end

    def log_last_visiting_time
      if current_user
        @user_log = current_user.user_logs.by_topic(@topic.id).first
        if @user_log
          @user_log.update_attribute(:updated_at, Time.now)
        else
          @user_log = UserLog.create(:user_id => current_user.id, :topic_id => @topic.id)
        end
      end
    end

    def log_new_feature_visiting_status
      @dont_show_new_features = []
      host_parts = request.host.split(/\./)
      host = host_parts[(host_parts.length - 2)..host_parts.length].join('.')

      if defined?(NEW_FEATURES)
        cookie = cookies[:new_feature]

        if cookie.nil?
          cookies[:new_feature] = {
            :domain => host,
            :value => '',
            :expires => 1.year.from_now
          }
        else
          key = "#{params[:controller]}_#{params[:action]}"
          NEW_FEATURES.each do |feature_name, feature|
            if !cookie.include?(feature_name.to_s) && feature[:unless_visited_on].include?(key)
              cookies[:new_feature] = {
                :domain => host,
                :value => "#{cookie}|#{feature_name.to_s}",
                :expires => 1.year.from_now
              }
              @dont_show_new_features << feature_name
            elsif cookie.include?(feature_name.to_s)
              @dont_show_new_features << feature_name
            end
          end
        end
      end
    end

end
