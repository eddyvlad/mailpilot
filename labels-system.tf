resource "gmailfilter_label" "system_chat" {
  label_list_visibility   = "labelHide"
  message_list_visibility = "hide"
  name                    = "CHAT"
}

resource "gmailfilter_label" "system_sent" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "hide"
  name                    = "SENT"
}

resource "gmailfilter_label" "system_inbox" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "hide"
  name                    = "INBOX"
}

resource "gmailfilter_label" "system_important" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "hide"
  name                    = "IMPORTANT"
}

resource "gmailfilter_label" "system_trash" {
  label_list_visibility   = "labelHide"
  message_list_visibility = "hide"
  name                    = "TRASH"
}

resource "gmailfilter_label" "system_draft" {
  label_list_visibility   = "labelShowIfUnread"
  message_list_visibility = "hide"
  name                    = "DRAFT"
}

resource "gmailfilter_label" "system_spam" {
  label_list_visibility   = "labelHide"
  message_list_visibility = "hide"
  name                    = "SPAM"
}

resource "gmailfilter_label" "system_category_forums" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "CATEGORY_FORUMS"
}

resource "gmailfilter_label" "system_category_updates" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "CATEGORY_UPDATES"
}

resource "gmailfilter_label" "system_category_personal" {
  name = "CATEGORY_PERSONAL"
}

resource "gmailfilter_label" "system_category_promotions" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "CATEGORY_PROMOTIONS"
}

resource "gmailfilter_label" "system_category_social" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "CATEGORY_SOCIAL"
}

resource "gmailfilter_label" "system_yellow_star" {
  name = "YELLOW_STAR"
}

resource "gmailfilter_label" "system_starred" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "hide"
  name                    = "STARRED"
}

resource "gmailfilter_label" "system_unread" {
  name = "UNREAD"

  lifecycle {
    ignore_changes = [
      label_list_visibility,
      message_list_visibility,
    ]
  }
}
