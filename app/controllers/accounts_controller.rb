class AccountsController < ApplicationController
  def edit
    @user = current_user
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
  
  def update
    @user = current_user
    if @user.update_with_password(params[:user])
      return redirect_to projects_path
    else
      return render :action => "edit"
    end
  end
end