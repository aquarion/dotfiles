---
name: "inbox-zero-triage"
description: "Clear Aquarion's Gmail inbox: trash pure promos, archive bulk mail, keep only things needing action, then summarise what's left. Use for \"clear out my inbox\" or \"do the inbox again\"."
---

# Inbox zero triage

The goal is an inbox that holds only what needs Aquarion's attention. Everything else is binned (pure marketing) or archived (still searchable in All Mail). This has been run before, so the rules below are settled. Don't ask about method again unless the user signals a change.

## Settled rules

**Trash (pure marketing):**
- Shop sales and offers: Fanatical, Humble, Just Eat, John Lewis, Waitrose, Nectar/Sainsbury's offers, Co-op, Kenwood, Approved Food and the like.
- DriveThruRPG publisher promos and "Follow your favourites".
- BackerKit/Kickstarter "X just backed Y", "coming soon" and "now live" promos.
- Instagram follow suggestions, Zoopla marketing, Eventbrite webinar spam.
- Promotional nudges from services (Wise referral, Dropbox features, Canva, IFTTT, OpenAI and GitHub marketing).
- Fyrion and rylan aliases forwarding store promos (smol 60% off, dog-holiday offers and so on).

**Archive (bulk but legitimate):**
- Newsletters: Substack, Ghost, Garbage Day, 404 Media, Guardian editions, Bloomberg, Aftermath and others.
- Patreon creator posts, Kickstarter and BackerKit project updates for backed projects.
- Delivery and dispatch tracking: Amazon, Royal Mail, DPD.
- Uptime and monitoring alerts that have recovered, i.e. a matching UP or "back online" message exists.
- Debian security advisories and MediaWiki announcements. These are list broadcasts.
- Routine Dependabot PRs, GitHub CI run failures, releases, and github/roadmap or other subscribed issues.
- Self-sent cistern cron copies (to nicholas+cisterncron@).
- Green Party and Unite mailings, Checkatrade nudges, order confirmations.
- Personal threads that have clearly concluded. Read the latest message to check.

**Keep in inbox (needs action):**
- **Payment problems:** failures, billing problems, suspended accounts, and subscription cancellations such as Cloudflare plans.
- **Security:** new sign-ins (Dropbox and similar), dark-web or exposure alerts, and GitHub "dependencies with security vulnerabilities" alerts.
- **Comment moderation:** support@istic.net "Please moderate" emails.
- **Server alerts still open:** Synology/cistern alerts (UPS, out-of-date packages) unless resolved.
- **Downloads to claim:** digital rewards, RR&D new files, BackerKit digital content, free DriveThruRPG copies.
- **Code reviews:** Copilot review comments and review requests on Aquarion's own PRs (bloom, Lifestream, bb-cli, stream-delta and so on).
- **Account actions:** wiki confirmations, "log in to keep your account", GitHub app permission requests.
- **Health and appointments:** dentist, NHS invitations.
- **Personal and financial:** mortgage, council tax, real people writing personally, Halifax inbox messages.
- **Receipts and invoices:** Apple, Google, Kiva, Stripe, Steam, Discord, ACRCloud, YouFibre and others.
- **Starred threads.**

When something is genuinely ambiguous, prefer archive over trash. Mention it in the summary.

## Process

1. Load the Gmail tools in one ToolSearch call: search_threads, get_thread, trash_thread, unlabel_thread, list_labels. Create a short task list.
2. **Page through the whole inbox first; don't act yet.** Query `in:inbox`, or `in:inbox after:YYYY/MM/DD` since the last run, with pageSize 50 and follow nextPageToken. Acting mid-pagination shifts the results.
   - If a page overflows to a saved file, read it compactly with jq: id, message count, CATEGORY label, sender, subject, snippet.
   - Gmail's CATEGORY_PROMOTIONS label is a useful hint, not a rule. Patreon posts land there too, and those get archived.
3. **Record decisions in files as you go.** In the scratchpad, keep `reviewed.txt` with every ID seen, plus `keep.txt` and `trash.txt`. Compute the archive list as reviewed minus keep minus trash. Check there's no overlap and that everything in trash was reviewed.
4. For threads where the preview isn't enough, call get_thread with MINIMAL. Use this for multi-message personal threads, where the snippet shows only the oldest messages, and for anything that might need action, such as a cancellation notice.
5. **Trash**, then **archive** with unlabel_thread `INBOX`. Run 30–40 parallel calls per batch and keep count against the list.
6. **Verify.** Re-query the inbox and confirm only the keepers remain. Classify any mail that arrived during the run.

## Payment failures

A payment failure usually has a matching success later. Before reporting a failure as outstanding, search for the success, including Trash (`includeTrash: true`) and archived mail.
- Look for a receipt or invoice from the same sender after the failure date.
- Or look for a "welcome back", "successfully charged" or upcoming-payment notice.

If you find a success, archive the failure notice and list it as resolved. Flag only the ones with no evidence, and say the account may still be fine. If the user says something is sorted, archive it.

## Summary format

Keep it short:
1. One line with the counts: trashed, archived, threads left.
2. **Check these first:** urgent items such as payment, security, cancellations and recurring server alerts.
3. **Other things that need you**, grouped. The usual groups are comments to moderate, code reviews, downloads, account actions and personal.
4. **Receipts:** one line listing them, noting they can be bulk-archived.
5. **Archived:** only the judgement calls worth knowing about. For example, a cluster of site outages that recovered, failing CI on a branch, or a personal thread that concluded.

Don't re-describe the whole inbox. Don't add sign-offs.
