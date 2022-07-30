class GroupsController < ApplicationController
  def new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
      if @group.update(group_params)
        redirect_to group_path(@group.id)
      else
        render 'edit'
      end
  end

  private

  def group_params
    params.require(:group).permit(:image, :name, :introduction)
  end
end
