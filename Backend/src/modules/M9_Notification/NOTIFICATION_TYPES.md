# Notification types (M9)

Shared enum for Flutter + Admin TopBar filters (`notif_prefs`).

| type | Audience | Typical action |
|------|----------|----------------|
| `test_result_synced` | student | Open All Tests / result |
| `preference_change_request` | admin | Users → Approve queue |
| `admin_subscription_changed` | admin | Users / Subscriptions |
| `post_flagged` | student | Community |
| `new_post` / community events | student+admin | Community tab |
| `notification:new` (socket) | both | Refresh inbox |

## Client parsing

Prefer: `{ success, data: { items, unread_count, meta } }`  
Legacy: `notifications`, `unreadCount` still returned.

## Badge vs prefs

Admin TopBar may hide types via `notif_prefs`; badge should reflect **visible** unread when prefs filter is on.

## Quiet hours (L7)

`notif_prefs` may also include:

| key | default | effect |
|-----|---------|--------|
| `quietHoursEnabled` | `false` | When true, **FCM push is skipped** during window |
| `quietStart` / `quietEnd` | `22:00` / `07:00` | Local HH:mm in `timezone` |
| `timezone` | `Asia/Karachi` | IANA tz for window |
| `digestEnabled` | `false` | Flag only (digest cron not wired) |

In-app DB notification + Socket.io still deliver during quiet hours.
