class TuringEmailApp.Collections.EmailAccountsCollection extends TuringEmailApp.Collections.BaseCollection

	currentEmailAccountIsAGmailAccount: ->
		@current_email_account_type == "GmailAccount"
