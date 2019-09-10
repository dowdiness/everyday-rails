require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  let(:user) { FactoryBot.create(:user) }
  let(:project) {
    FactoryBot.create(:project,
      name: "RSpec tutorial",
      owner: user)
  }
  # ユーザーは新しいプロジェクトを作成する
  scenario "user creates a new project" do
    sign_in user
    visit root_path

    expect {
      create_project("Test Project", "Trying out Capybara")
    }.to change(user.projects, :count).by(1)

    aggregate_failures do
      expect(page).to have_content "Project was successfully created"
      expect(page).to have_content "Test Project"
      expect(page).to have_content "Owner: #{user.name}"
    end

  end

  scenario "user edits a project" do
    sign_in user

    visit project_path(project)
    expect {
      edit_project("Edited Project", "Trying out helper method")
    }.to change(user.projects, :count).by(0)

    aggregate_failures do
      expect(page).to have_content "Project was successfully updated"
      expect(page).to have_content "Edited Project"
      expect(page).to have_content "Trying out helper method"
      expect(page).to have_content "Owner: #{user.name}"
    end
  end

  # ユーザーはプロジェクトを完了済みにする
  scenario "user completes a project" do
    sign_in user
    visit project_path(project)

    expect(page).to_not have_content "Completed"

    click_button "Complete"
    expect(project.reload.completed?).to be true
    expect(page).to have_content "Congratulations, this project is complete!"
    expect(page).to have_content "Completed"
    expect(page).to_not have_button "Complete"

    #プロジェクトを持ったユーザーを準備する
    #ユーザーはログインしている
    #ユーザーがプロジェクト画面を開き、
    #"complete" ボタンをクリックすると、
    #プロジェクトは完了済みとしてマークされる
  end

  def create_project(name, description)
    click_link "New Project"
    fill_in "Name", with: name
    fill_in "Description", with: description
    click_button "Create Project"
  end

  def edit_project(name, description)
    click_link "Edit"
    fill_in "Name", with: name
    fill_in "Description", with: description
    click_button "Update Project"
  end
end
