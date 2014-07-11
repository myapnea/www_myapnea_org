class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :determine_pprn
  layout 'pages'


  # Prototype Pages
  def account; end
  def admin; end
  def blog; end
  def connections; end
  def contributions; end
  def data; end
  def donate; end
  def health_profile; end
  def home; end
  def index; end
  def insights; end
  def join; end
  def login; end
  def new_question; end
  #def pp-addons; end
  def research; end
  def research_question; end
  def social; end
  def social_profile; end
  def survey; end


  # Read the PPRN Cookie
  def determine_pprn
    @pprn = cookies[:pprn]

    if @pprn == "ccfa"
      # CCFA
      @pprn_title = "CCFA PPRN"
      @pprn_condition = "Crohn's & Colitis"
    else @pprn == "sapcon"
      # SAPCON
      @pprn_title = "Sleep Apnea PPRN"
      @pprn_condition = "Sleep Apnea"
    end
  end

  #Toggle the PPRN from CCFA <-> SAPCON
  def pprn
    if cookies[:pprn] == "ccfa"
      cookies[:pprn] = "sapcon"
    elsif cookies[:pprn] == "sapcon"
      cookies[:pprn] = "ccfa"
    end

    redirect_to root_path
  end

end
