resource "gmailfilter_filter" "newsletter_archive" {
  criteria {
    from           = "news@newsletter.example"
    exclude_chats  = false
    has_attachment = false
  }
  action {
    add_label_ids    = [gmailfilter_label.newsletters.id]
    remove_label_ids = ["INBOX", "SPAM"]
  }
}
