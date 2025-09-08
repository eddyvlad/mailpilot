module "bills_filter" {
  source   = "./modules/bills-filter"
  label_id = gmailfilter_label.bills.id
}

module "deliveries_filter" {
  source   = "./modules/deliveries-filter"
  label_id = gmailfilter_label.deliveries.id
}

module "receipts_filter" {
  source   = "./modules/receipts-filter"
  label_id = gmailfilter_label.receipts.id
}

module "transport_receipts_filter" {
  source   = "./modules/transport-receipts-filter"
  label_id = gmailfilter_label.transport_receipts.id
}
