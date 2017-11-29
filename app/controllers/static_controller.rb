# frozen_string_literal: true

# Displays static pages for public users.
class StaticController < ApplicationController
  # GET /about
  def about
    render layout: "layouts/full_page_no_header"
  end

  # GET /team
  def team
    @team_members = Admin::TeamMember.current.order(:position)
  end

  # GET /partners
  def partners
    @partners = Admin::Partner.current.where(displayed: true).order(:position)
  end

  # # GET /version
  # def version
  # end
end
