class ApplicationController < ActionController::Base

  after_filter :framed_report_page_view

  def framed_report_page_view
    begin
      anonymous_id = cookies.signed[Framed.anonymous_cookie]
      user_id = send(Framed.user_id_controller_method)

      if user_id.nil? && anonymous_id.nil?
        anonymous_id = Framed.new_anonymous_id
        cookies.signed.permanent[Framed.anonymous_cookie] = { :value => anonymous_id, :httponly => true}
      end

      Framed.report({
        :anonymousId => anonymous_id,
        :userId => user_id,
        :event   => "page_view",
        :controller_name => controller_name,
        :action_name => action_name,
        :path => request.path
      })
    rescue StandardError => exc
      Framed.logger("Failed to report page_view #{exc}")
    end
  end

  def framed_devise_user_id
    current_user.try(:email)
  end
end