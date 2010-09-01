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
    saved = @user.update_with_password(params[:user])
    respond_to do |wants|
      wants.html do
        return redirect_to projects_path if saved
        return render :action => "edit"
      end
      wants.js do
        return render :action => (saved ? "update" : "edit")
      end
    end
  end
end