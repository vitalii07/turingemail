require "rails_helper"

describe "Welcome Tour", type: :feature, js: true do
  shared_examples 'no Welcome Tour modal displayed' do

    it "does not display the Welcome Tour modal" do
      expect(page).to_not have_selector(".tour-modal.in")
    end

  end

  shared_examples 'Welcome Tour modal displayed' do

    it "displays the Welcome Tour modal" do
      expect(page).to have_selector(".tour-modal.in")
      expect(page).to have_text 'Welcome.'
    end

  end

  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "by default" do

    it_behaves_like 'no Welcome Tour modal displayed'

  end

  context "when the user clicks the options dropdown" do
    before { find(".tm_user-details").click }

    it_behaves_like 'no Welcome Tour modal displayed'

    context "when the user does not click the Welcome Tour option" do

      it_behaves_like 'no Welcome Tour modal displayed'

    end

    context "when the user clicks the Welcome Tour option" do
      before { click_link("Take the Tour") }

      it_behaves_like 'Welcome Tour modal displayed'

    end

  end

  context "when the user does not click the options dropdown" do

    it_behaves_like 'no Welcome Tour modal displayed'

  end

  context "when the user navigates to the welcome tour url" do
    before { visit '/mail#welcome_tour' }

    it_behaves_like 'Welcome Tour modal displayed'

  end

  context "when the user opens the welcome tour" do
    before do
      find(".tm_user-details").click
      click_link("Take the Tour")
    end

    it_behaves_like 'Welcome Tour modal displayed'

    context "when the next button is clicked" do
      before { find(".tm_tour-next").click }

      it "displays the second slide of the Welcome Tour modal" do
        expect(page).to have_text "We’ve built a suite of features to help you accomplish more every day. This is the most useful email product you’ll ever use."
      end

      context "when the next button is clicked" do
        before { find(".tm_tour-next").click }

        it "displays the third slide of the Welcome Tour modal" do
          expect(page).to have_text "Email like messenger."
          expect(page).to have_text "Email contacts in a messaging style with quick, back and forth conversations, all while the content remains sorted and searchable in your inbox. Never lose information in personal message threads."
        end

        context "when the next button is clicked" do
          before { find(".tm_tour-next").click }

          it "displays the fourth slide of the Welcome Tour modal" do
            expect(page).to have_text "A better connection."
            expect(page).to have_text "As you’re composing, view your contact’s personal information, 1-to-1 email history, and current social media activity. Write more relevant emails with our Contact Sidebar."
          end

          context "when the next button is clicked" do
            before { find(".tm_tour-next").click }

            it "displays the fifth slide of the Welcome Tour modal" do
              expect(page).to have_text "Write now, send later."
              expect(page).to have_text "Compose emails now and schedule them for future arrival. Display impeccable timing and email etiquette."
            end

            context "when the next button is clicked" do
              before { find(".tm_tour-next").click }

              it "displays the sixth slide of the Welcome Tour modal" do
                expect(page).to have_text "Track an email to 'open'."
                expect(page).to have_text "Track any communication with ease. Know who’s opened emails and who hasn’t to plan relevant next steps."
              end

              context "when the next button is clicked" do
                before { find(".tm_tour-next").click }

                it "displays the seventh slide of the Welcome Tour modal" do
                  expect(page).to have_text "Templates for consistency."
                  expect(page).to have_text "Create email templates for consistent communication with easy accessibility."
                end

                context "when the next button is clicked" do
                  before { find(".tm_tour-next").click }

                  it "displays the eighth slide of the Welcome Tour modal" do
                    expect(page).to have_text "A library of attachments"
                    expect(page).to have_text "View every email attachment in a single list. Locate the file you need without clicking through threads of messages."
                  end

                  context "when the next button is clicked" do
                    before { find(".tm_tour-next").click }

                    it "displays the ninth slide of the Welcome Tour modal" do
                      expect(page).to have_text "Solve email overwhelm."
                      expect(page).to have_text "Inbox Cleaner analyzes your inbox then groups like emails for easy batch archiving. A faster way to clear your inbox."
                    end

                    context "when the next button is clicked" do
                      before { find(".tm_tour-next").click }

                      it "displays the tenth slide of the Welcome Tour modal" do
                        expect(page).to have_text "Sign in style."
                        expect(page).to have_text "Create multiple signature styles for all your email identities."
                      end

                      context "when the next button is clicked" do
                        before { find(".tm_tour-next").click }

                        it "displays the eleventh slide of the Welcome Tour modal" do
                          expect(page).to have_text "Real-Time Monitoring."
                          expect(page).to have_text "Analytics drive action. Learn details about your email usage such as who you connect with the most and high-activity email threads to spend email time more effectively."
                        end

                        context "when the next button is clicked" do
                          before { find(".tm_tour-next").click }

                          it "displays the twelth slide of the Welcome Tour modal" do
                            expect(page).to have_text "Smart follow up."
                            expect(page).to have_text "Remind yourself of an unanswered email by having it reappear in your inbox. Take swift follow up action and never let an email be forgotten."
                          end

                          context "when the next button is clicked" do
                            before { find(".tm_tour-next").click }

                            it "displays the thirteenth slide of the Welcome Tour modal" do
                              expect(page).to have_text "Manage subscriptions."
                              expect(page).to have_text "Take action on active subscriptions from one page with one click. Clear the bothersome and keep the enlightening."
                            end

                            context "when the next button is clicked" do
                              before { find(".tm_tour-next").click }

                              it "displays the fourtheen slide of the Welcome Tour modal" do
                                expect(page).to have_text "Seamless integration."
                                expect(page).to have_text "Salesforce, Desk.com, and Zendesk integration coming next. Make your email even more powerful with integration into your current business software products."
                              end

                              context "when the next button is clicked" do
                                before { find(".tm_tour-next").click }

                                it "displays the fiftheen slide of the Welcome Tour modal" do
                                  expect(page).to have_text "Your emails are syncing."
                                  expect(page).to have_text "This process could take some time depending on the number of emails in your inbox, but you can start using your Turing Email account right away."
                                end

                              end

                            end

                          end

                        end

                      end

                    end

                  end

                end

              end

            end

          end

        end

      end

    end

  end

end