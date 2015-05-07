class ResearchTopicsController < ApplicationController
  before_action :authenticate_user!

  before_action :no_layout,                           only: [ :research_topics ]
  before_action :set_research_topic,                  only: [ :show, :update, :edit, :destroy ]
  before_action :set_active_top_nav_link_to_research

  authorize_actions_for ResearchTopic, only: [:index, :create, :new]

  def intro
  end

  def first_topics
    @research_topics = ResearchTopic.accepted.first(10)
  end

  def newest
    @rt_c1 = []
    @rt_c2 = []
    ResearchTopic.accepted.each_with_index do |rt, index|
      (index+1)%2==0 ? (@rt_c1 << rt) : (@rt_c2 << rt)
    end
  end

  def most_discussed
    @research_topics = ResearchTopic.accepted
  end

  def all
    @research_topics = ResearchTopic.accepted
  end

  def index
    @active_top_nav_link = :research
    if current_user.votes.where(rating: 1).count < 1
      redirect_to intro_research_topics_path
    end
    @research_topics = ResearchTopic.accepted
  end

  def show
    @active_top_nav_link = :research
    authorize_action_for @research_topic
  end

  def new
    @active_top_nav_link = :research
    @research_topic = current_user.research_topics.new
  end

  def edit
    @active_top_nav_link = :research
    authorize_action_for @research_topic
  end

  def create
    @research_topic = current_user.research_topics.new(research_topic_params)

    if @research_topic.save
      redirect_to research_topics_path, notice: "Your research topic has been successfully submitted!"
    else
      render :new
    end
  end

  def update
    authorize_action_for @research_topic

    if @research_topic.update(research_topic_params)
      if current_user.can_moderate?(@research_topic)
        redirect_to admin_research_topic_path(@research_topic), notice: "Your research topic has been successfully updated!"
      else
        redirect_to research_topic_path(@research_topic), notice: "Your research topic has been successfully updated!"
      end
    else
      if current_user.can_moderate?(@research_topic)
        redirect_to admin_research_topics_path, error: "There were problems updating your research topic."
      else
        flash[:error] = "There were problems updating your research topic."
        render :edit
      end

    end
  end

  def destroy
    authorize_action_for @research_topic

    @research_topic.destroy

    if current_user.has_role? :moderator
      redirect_to admin_research_topics_path, notice: "Research topic deleted!"
    else
      redirect_to research_topics_path, notice: "Research topic deleted!"
    end

  end

  private

  def research_topic_params
    if current_user.has_role? :moderator
      params.require(:research_topic).permit(:text, :description, :state)
    else
      params.require(:research_topic).permit(:text, :description)
    end
  end

  def set_research_topic
    @research_topic = ResearchTopic.find_by_id(params[:id])
  end

end
