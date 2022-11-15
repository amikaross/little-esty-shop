class ApplicationController < ActionController::Base
  before_action :get_info,   only: [:index, :show, :new, :edit]

  def get_info
    # @repo_name = GithubSearch.new.repo_information
    # contributors = GithubSearch.new.contributor_names
    # @contributors = contributors.sort_by {|contributor| contributor.num_commits}.last(6)
    # @latest_pr = GithubSearch.new.num_pulls

    @repo_name = Repo.new("little-esty-shop")
    @contributors = [Contributor.new({total: 56, author: {login: "josephhilby"}}), Contributor.new({total: 13, author: {login: "ashuhleyt"}}), Contributor.new({total: 34, author: {login: "AlexMR-93"}}), Contributor.new({total: 46, author: {login: "amikaross"}}) ]
    @latest_pr = Pull.new({number: 37})
  end

  def error_message(errors)
    errors.details.keys.map do |field|
      errors.full_messages_for(field).first
    end.join(", ") 
  end
end
