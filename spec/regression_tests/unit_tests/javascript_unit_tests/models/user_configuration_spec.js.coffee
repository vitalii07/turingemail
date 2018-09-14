describe "UserConfiguration", ->
  beforeEach ->
    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()

  describe "Class Variables", ->
    describe "#EmailThreadsPerPage", ->
      it "returns 30", ->
        expect( TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage ).toEqual 30

  describe "Instance Variables", ->
    describe "#url", ->
      it "returns '/api/v1/user_configurations'", ->
        expect(@userConfiguration.url).toEqual("/api/v1/user_configurations")

  describe "Validation", ->
    it "is required the automatic_inbox_cleaner_enabled true", ->
      expect( @userConfiguration.validation.automatic_inbox_cleaner_enabled.required ).toBeTruthy
    it "is required the split_pane_mode true", ->
      expect( @userConfiguration.validation.split_pane_mode.required ).toBeTruthy


