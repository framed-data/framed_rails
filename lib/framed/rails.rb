class ApplicationController < ActionController::Base

  after_filter :framed_report_page_view

  def pv_event_name
    "#{request.method}_#{params[:controller]}\##{params[:action]}"
  end

  def framed_report_page_view
    begin
      anonymous_id = cookies.signed[Framed.anonymous_cookie]
      user_id = send(Framed.user_id_controller_method)

      if user_id.nil? && anonymous_id.nil?
        anonymous_id = Framed.new_anonymous_id
        cookies.signed.permanent[Framed.anonymous_cookie] = { :value => anonymous_id, :httponly => true}
      end

      Framed.report({
        :anonymous_id => anonymous_id,
        :user_id => user_id,
        :event   => pv_event_name,
        :properties => Framed::Utils.flattened_hash({
          :params => params,
          :request_method => request.method,
          :path => request.path
        })
      })
    rescue StandardError => exc
      Framed.logger.error("Failed to report page_view #{exc}")
    end
  end

  def framed_devise_user_id
    current_user.try(:email)
  end
end