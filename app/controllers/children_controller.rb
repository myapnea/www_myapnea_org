class ChildrenController < ApplicationController
  before_action :authenticate_user!

  before_action :set_child,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_child,  only: [:show, :edit, :update, :destroy]

  # GET /children
  # GET /children.json
  def index
    @children = current_user.children
  end

  # GET /children/1
  # GET /children/1.json
  def show
  end

  # GET /children/new
  def new
    @child = current_user.children.new
  end

  # GET /children/1/edit
  def edit
  end

  # POST /children
  # POST /children.json
  def create
    @child = current_user.children.new(child_params)

    respond_to do |format|
      if @child.save
        format.html { redirect_to @child, notice: 'Child was successfully created.' }
        format.json { render :show, status: :created, location: @child }
      else
        format.html { render :new }
        format.json { render json: @child.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /children/1
  # PATCH/PUT /children/1.json
  def update
    respond_to do |format|
      if @child.update(child_params)
        format.html { redirect_to @child, notice: 'Child was successfully updated.' }
        format.json { render :show, status: :ok, location: @child }
      else
        format.html { render :edit }
        format.json { render json: @child.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /children/1
  # DELETE /children/1.json
  def destroy
    @child.destroy
    respond_to do |format|
      format.html { redirect_to children_path, notice: 'Child was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_child
      @child = current_user.children.find_by_id(params[:id])
    end

    def redirect_without_child
      empty_response_or_root_path(children_path) unless @child
    end

    def child_params
      params.require(:child).permit(:first_name, :age)
    end
end