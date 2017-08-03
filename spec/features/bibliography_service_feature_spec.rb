require 'rails_helper'

describe 'Bibliography Service', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { nil }

  before do
    sign_in user
  end

  context 'an authorized user' do
    let(:user) { create(:exhibit_admin, exhibit: exhibit) }

    # Travis may be timing out in an odd way on this feature
    xit 'can edit the service configurations' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within('#sidebar') do
        click_link 'Services'
      end

      fill_in 'Section heading', with: 'My New Header'
      fill_in 'Zotero ID', with: 'abc123'
      choose 'User'

      click_button 'Save changes'

      expect(field_labeled('Section heading').value).to eq 'My New Header'
      expect(field_labeled('Zotero ID').value).to eq 'abc123'
      expect(field_labeled('User')[:checked]).to eq 'checked'
      expect(field_labeled('Group')[:checked]).to be_nil

      object = BibliographyService.last
      expect(object.header).to eq 'My New Header'
      expect(object.api_id).to eq 'abc123'
      expect(object.api_type).to eq 'user'
    end

    it 'includes breadcrumbs on the edit page' do
      visit edit_exhibit_services_path(exhibit)

      within('ul.breadcrumb') do
        expect(page).to have_link 'Home'
        expect(page).to have_link 'Configuration'
        expect(page).to have_css('li.active', text: 'Services')
      end
    end
  end
end
