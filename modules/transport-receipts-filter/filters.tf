locals {
  default_action = {
    add_label_ids = [var.label_id]
    remove_label_ids = ["INBOX", "SPAM"]
  }

  default_criteria = {
    exclude_chats  = "false"
    has_attachment = "false"
  }

  criterias = {
    grab = {
      query = "from:grab \"your ride\""
    }
  }
}

resource "gmailfilter_filter" "transport_receipts" {
  for_each = local.criterias

  action {
    add_label_ids    = local.default_action.add_label_ids
    remove_label_ids = local.default_action.remove_label_ids
  }

  criteria {
    exclude_chats  = local.default_criteria.exclude_chats
    has_attachment = local.default_criteria.has_attachment
    query = lookup(each.value, "query", null)
  }
}
