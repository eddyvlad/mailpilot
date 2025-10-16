#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

terraform import gmailfilter_label.system_chat CHAT
terraform import gmailfilter_label.system_sent SENT
terraform import gmailfilter_label.system_inbox INBOX
terraform import gmailfilter_label.system_important IMPORTANT
terraform import gmailfilter_label.system_trash TRASH
terraform import gmailfilter_label.system_draft DRAFT
terraform import gmailfilter_label.system_spam SPAM
terraform import gmailfilter_label.system_category_forums CATEGORY_FORUMS
terraform import gmailfilter_label.system_category_updates CATEGORY_UPDATES
terraform import gmailfilter_label.system_category_personal CATEGORY_PERSONAL
terraform import gmailfilter_label.system_category_promotions CATEGORY_PROMOTIONS
terraform import gmailfilter_label.system_category_social CATEGORY_SOCIAL
terraform import gmailfilter_label.system_yellow_star YELLOW_STAR
terraform import gmailfilter_label.system_starred STARRED
terraform import gmailfilter_label.system_unread UNREAD
