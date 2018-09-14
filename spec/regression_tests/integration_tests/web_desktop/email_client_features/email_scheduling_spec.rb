require 'rails_helper'

describe 'Scheduling', type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
  let(:modal_window_selector) { '.compose-modal.in' }
  let(:compose_form_container) { find('.tm_schedule-compose') }
  let(:compose_datetimepicker) { compose_form_container.find('.datetimepicker') }
  let(:compose_button) { compose_form_container.find('.tm_button-submit') }

  context 'create email' do
    include_context 'email scheduling'

    context 'date is not selected' do
      before do
        compose_button.click
      end

      xit 'should return alert notification' do
        expect(page).to have_text('Please select date')
      end

      xit 'should not find modal window' do
        expect(page).not_to have_selector(modal_window_selector)
      end
    end

    context 'selected past date' do
      let(:time) { datetimepicker_value(DateTime.now - 1.hour) }

      before do
        compose_datetimepicker.set(time)
        compose_button.click
      end

      xit 'should return alert notification' do
        expect(page).to have_text('Datetime is incorrect')
      end

      xit 'should not find modal window' do
        expect(page).not_to have_selector(modal_window_selector)
      end
    end

    context 'selected future date' do
      let(:time) { datetimepicker_value(DateTime.now + 1.hour) }

      before do
        compose_datetimepicker.set(time)
        compose_button.click
      end

      xit 'should find modal window' do
        expect(page).to have_selector(modal_window_selector)
      end

      # context 'modal window' do
      #   let(:modal_form) { find(modal_window_selector).find('.compose-form') }
      #   let(:to_input) { modal_form.find('.to-input') }
      #   let(:subject_input) { modal_form.find('.subject-input') }
      #   let(:email_body_input) { modal_form.find('.redactor-editor') }
      #   let(:tracking_switch_input) { modal_form.find('.tracking-switch') }

      #   # reminders
      #   let(:reminder_button) { modal_form.find('.dropdown-reminder-button') }
      #   let(:reminder_dropdown) { modal_form.find('.dropdown-reminder') }
      #   let(:never_remind_element) { reminder_dropdown.find('li:nth-child(0) div') }
      #   let(:always_remind_element) { reminder_dropdown.find('li:nth-child(1) div') }
      #   let(:remind_if_not_reply_element) { reminder_dropdown.find('li:nth-child(2) div') }
      #   let(:remind_datetime) { reminder_dropdown.find('.reminder-datetimepicker') }

      #   let(:send_later_datetimepicker){ modal_form.find('.send-later-datetimepicker') }

      #   # submit buttons
      #   let(:main_submit_button){ modal_form.find('.main-send-button') }
      #   let(:submit_dropdown_button){ modal_form.find('.tm_button-stack .tm_button-caret') }
      #   let(:submit_dropdown){ modal_form.find('.send-button-dropdown-menu') }
      #   let(:send_button) { submit_dropdown.find('.send-button') }
      #   let(:send_and_archive_button) { submit_dropdown.find('.send-and-archive-button') }
      #   let(:save_button) { submit_dropdown.find('.save-button') }

      #   let(:valid_options) do
      #     { to: 'test@test.com', subject: 'Test', email_body: 'Test '*10 }
      #   end

      #   # used as default
      #   context 'Send Later' do
      #     let(:time) { datetimepicker_value(DateTime.now + 12.hours) }

      #     it 'should have expected button name' do
      #       expect(main_submit_button.find('.send-button-text')).to have_text('Send Later')
      #     end

      #     context 'fill valid data into form fields' do
      #       before do
      #         valid_options.each do |field, value|
      #           send(:"#{field}_input").set(value)
      #         end

      #         send_later_datetimepicker.set(time)
      #         main_submit_button.click
      #       end

      #       it 'should see notification of new email' do
      #         expect(page).to have_text('Your message has been sent.')
      #       end
      #     end

      #     context 'fill invalid data into form fields' do
      #       before do
      #         send_later_datetimepicker.set(time)
      #         main_submit_button.click
      #       end

      #       it_behaves_like 'incorrect email'
      #     end
      #   end

      #   context 'Save Draft' do
      #     before do
      #       expect_any_instance_of(GmailAccount).to receive(:create_draft).and_return({})
      #     end

      #     context 'fill valid data into form fields' do
      #       before do
      #         valid_options.each do |field, value|
      #           send(:"#{field}_input").set(value)
      #         end

      #         submit_dropdown_button.click
      #         save_button.click
      #       end

      #       it 'should see notification of new draft email' do
      #         expect(page).to have_text('Email draft saved.')
      #       end
      #     end

      #     context 'fill valid data into form fields' do
      #       before do
      #         submit_dropdown_button.click
      #         save_button.click
      #       end

      #       it 'should see notification of new draft email' do
      #         expect(page).to have_text('Email draft saved.')
      #       end
      #     end
      #   end
      # end
    end
  end

  let(:selectors) do
    {
      to: '.email-from',
      subject: '.tm_email-subject',
      text_part: '.tm_email-body',
      edit_link: '.edit-delayed-email-button',
      send_link: '.send-delayed-email-button',
      delete_link: '.delete-delayed-email-button',
      confirmation_dialog: '.confirmation-modal-dialog',
      yes_button: '.yes-button',
      no_button: '.no-button'
    }
  end

  context 'listing' do
    include_context 'with_existing_entities'

    include_context 'email scheduling'

    it 'should show all delayed emails' do
      @delayed_emails.each do |de|
        selector = delayed_email_selector(de)
        expect(page).to have_selector(selector)
        container = find(selector)
        expect(container.find(selectors[:to])).to have_text(de.tos.join(', '))
        expect(container.find(selectors[:subject])).to have_text(de.subject)
        expect(container.find(selectors[:text_part])).to have_text(de.text_part)
      end
    end
  end

  context 'edit' do
    include_context 'with_existing_entities'

    include_context 'email scheduling'

    before do
      @de = @delayed_emails.first
      @container = find(delayed_email_selector(@de))
    end

    it 'should find modal' do
      @container.find(selectors[:edit_link]).click
      expect(page).to have_selector(modal_window_selector)
    end

    # story 1
    # 1. change fields with valid params
    # 2. click 'Save'
    # 3. check updates of @de

    # story 2
    # 1. change fields with invalid params
    # 2. click 'Save'
    # 3. see alerts
  end

  context 'delete' do
    include_context 'with_existing_entities'

    include_context 'email scheduling'

    before do
      @de = @delayed_emails.first
      @container = find(delayed_email_selector(@de))
      @container.find(selectors[:delete_link]).click
    end

    context 'confirm deletion' do
      before do
        find(selectors[:confirmation_dialog]).find(selectors[:yes_button]).click
      end

      # it 'should delete delayed email' do
      #   expect(DelayedEmail.find_by_id(@de.id)).to be_nil
      # end

      it 'should not find deleted email on listing' do
        expect(page).not_to have_selector(delayed_email_selector(@de))
      end

      it 'should return alert notification' do
        expect(page).to have_text('Deleted scheduled email successfully.')
      end
    end

    context 'decline deletion' do
      before do
        find(selectors[:confirmation_dialog]).find(selectors[:no_button]).click
      end

      it 'should not delete delayed email' do
        expect(DelayedEmail.find_by_id(@de.id)).to eq(@de)
      end

      it 'should find deleted email on listing' do
        expect(page).to have_selector(delayed_email_selector(@de))
      end
    end
  end
end