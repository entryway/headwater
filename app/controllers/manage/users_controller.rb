module Manage
  class UsersController < ApplicationController
    def index
      @users = User.all
    end
  
    def edit
      @user = User.find(params[:id])
    end
  
    def update
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        redirect_to manage_users_path
      else
        render :action => 'edit'
      end
    end
  
    def new
      @user = User.new
    end
  
    def create
      @user = User.new(params[:user])
      if @user.save
        redirect_to manage_users_path
      else
        render :action => 'new'
      end
    end
    
    def destroy
      User.find(params[:id]).delete
      redirect_to manage_users_path
    end
  end
end