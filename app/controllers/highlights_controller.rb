# frozen_string_literal: true

class HighlightsController < ApplicationController
  before_action :authenticate_user!,      except: [:photo]
  before_action :check_owner,             except: [:photo]
  before_action :set_highlight,           only: [:show, :edit, :update, :destroy, :photo]

  before_action :set_SEO_elements

  layout 'admin'

  def photo
    if @highlight.photo.size > 0
      send_file File.join(CarrierWave::Uploader::Base.root, @highlight.photo.url)
    else
      head :ok
    end
  end

  # GET /highlights
  # GET /highlights.json
  def index
    @highlights = Highlight.current
  end

  # GET /highlights/1
  # GET /highlights/1.json
  def show
  end

  # GET /highlights/new
  def new
    @highlight = Highlight.new
  end

  # GET /highlights/1/edit
  def edit
  end

  # POST /highlights
  # POST /highlights.json
  def create
    @highlight = Highlight.new(highlight_params)

    respond_to do |format|
      if @highlight.save
        format.html { redirect_to @highlight, notice: 'Highlight was successfully created.' }
        format.json { render :show, status: :created, location: @highlight }
      else
        format.html { render :new }
        format.json { render json: @highlight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /highlights/1
  # PATCH/PUT /highlights/1.json
  def update
    respond_to do |format|
      if @highlight.update(highlight_params)
        format.html { redirect_to highlights_path, notice: 'Highlight was successfully updated.' }
        format.json { render :show, status: :ok, location: @highlight }
      else
        format.html { render :edit }
        format.json { render json: @highlight.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /highlights/1
  # DELETE /highlights/1.json
  def destroy
    @highlight.destroy
    respond_to do |format|
      format.html { redirect_to highlights_url, notice: 'Highlight was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_highlight
      @highlight = Highlight.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def highlight_params
      params.require(:highlight).permit(:title, :description, :photo, :display_date, :displayed, :research_highlight, :link)
    end

    def set_SEO_elements
      @page_title = @highlight.present? ? ('News - ' + @highlight.title) : 'Sleep Apnea Recent News Highlights'
      @page_content = 'Recent news highlights related to sleep apnea, sleep apnea treatment and CPAP devices, sleep research, and our growing sleep apnea community.'
    end

end
