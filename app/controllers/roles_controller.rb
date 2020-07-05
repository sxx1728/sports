# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string(128)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(128)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(128)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(128)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  approved               :boolean          default(FALSE), not null
#

class RolesController < ApplicationController

  before_action :authorize_ability

  def authorize_ability
    authorize! :manage, Role
  end


  def index
    @admin = Admin.find(params[:admin_id])
    @roles = @admin.roles
  end

  def new
    @admin = Admin.find(params[:admin_id])
    @role = Role.new
  end

  def create
    @admin = Admin.find(params[:admin_id])
    real_params = role_params
    if @admin.add_role(real_params[:name].to_sym)
      redirect_to admin_roles_path(@admin), notice: '创建成功！'
    else
      render action: 'new', alert: '创建失败！'
      redirect_back(fallback_location: new_admin_role_path(admin_id: @admin.id), alert: '创建失败')
    end
  end
 
  def destroy
    @admin = Admin.find(params[:admin_id])
    role = Role.find(params[:id])
    @admin.roles.delete(role)
    @roles = @admin.roles
    redirect_back(fallback_location: admin_roles_path(@admin), alert: '删除成功')
  end

  protected
  def role_params
    params.require(:role).permit!
  end

end
