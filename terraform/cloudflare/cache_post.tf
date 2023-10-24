resource "cloudflare_worker_route" "cache_post" {
  zone_id     = cloudflare_zone.intermittent.id
  pattern     = "intermittent.energy/api/ds/query*"
  script_name = cloudflare_worker_script.cache_post.name
}

resource "cloudflare_worker_script" "cache_post" {
  account_id = cloudflare_account.intermittent.id
  name       = "intermittent-energy"
  content    = file("cache_post.js")
}
