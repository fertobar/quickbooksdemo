class QuickbooksController < ApplicationController

  def authenticate
    callback = oauth_callback_quickbooks_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']
    flash.notice = "Your QuickBooks account has been successfully linked."
    @msg = 'Redirecting. Please wait.'
    @url = vendors_path
    render 'vendors/close_and_redirect', layout: false
  end

  def disconnect
    set_qb_service('AccessToken')
    result = @service.disconnect
    if result.error_code == '270'
      msg = 'Disconnect failed as OAuth token is invalid. Try connecting again.'
    else
      msg = 'Successfully disconnected from QuickBooks'
    end
    session[:token] = nil
    session[:secret] = nil
    session[:realm_id] = nil
    redirect_to vendors_path, notice: msg
  end



end
