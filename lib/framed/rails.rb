ActionController::Base.class_eval do

  after_filter :framed_report_request

  def framed_event_name
    "#{request.method}_#{params[:controller]}\##{params[:action]}"
  end

  def framed_included?(request)
    return true if Framed.configuration[:include_xhr]
    # include Turbolinks requests (which are a special kind of XHR)
    return true if request.headers.include?('X-XHR-Referer')

    !request.xhr?
  end

  def framed_report_request
    begin
      anonymous_id = cookies.signed[Framed.anonymous_cookie]
      user_id = send(Framed.user_id_controller_method)

      if user_id.nil? && anonymous_id.nil?
        anonymous_id = Framed.new_anonymous_id
        cookies.signed.permanent[Framed.anonymous_cookie] = { :value => anonymous_id, :httponly => true}
      end

      return unless framed_included?(request)

      cleaned_params = params.except(:controller, :action).to_h
      event = {
        :type => :track,
        :anonymous_id => anonymous_id,
        :user_id => user_id,
        :event   => framed_event_name,
        :context => {
          :path => request.path,
          :request_method => request.method,
          :rails_controller => params[:controller],
          :rails_action => params[:action]
        },
        :properties => Framed::Utils.flattened_hash({
          :params => cleaned_params
        })
      }

      Framed.report(event)
    rescue StandardError => exc
      Framed.logger.error("Failed to report request #{exc}")
    end
  end

  def framed_devise_user_id
    current_user.try(:id)
  end
end