resource "gmailfilter_label" "newsletters" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "Newsletters"
}

resource "gmailfilter_label" "bills" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "Bills"
}

resource "gmailfilter_label" "deliveries" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "Deliveries"
}

resource "gmailfilter_label" "receipts" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "Receipts"
}

resource "gmailfilter_label" "transport_receipts" {
  label_list_visibility   = "labelShow"
  message_list_visibility = "show"
  name                    = "Receipts/Transport Receipts"
}
