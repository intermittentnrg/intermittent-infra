export default {
  async fetch(request, env, ctx) {
    async function sha256(message) {
      // encode as UTF-8
      const msgBuffer = await new TextEncoder().encode(message);
      // hash the message
      const hashBuffer = await crypto.subtle.digest("SHA-256", msgBuffer);
      // convert bytes to hex string
      return [...new Uint8Array(hashBuffer)]
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");
    }
    try {
      if (request.method.toUpperCase() === "POST") {
        // increase caching
        const bodyJSON = JSON.parse(await request.clone().text());
        bodyJSON.from = Math.floor(bodyJSON.from/3600000)*3600000;
        bodyJSON.to = Math.floor(bodyJSON.to/3600000)*3600000;
        if(bodyJSON.range) {
          bodyJSON.range.from = null;
          bodyJSON.range.to = null;
        }
        //console.log(bodyJSON.from);
        //console.log(bodyJSON.to);
        const body = JSON.stringify(bodyJSON);

        // Hash the request body to use it as a part of the cache key
        const hash = await sha256(body);
        const cacheUrl = new URL(request.url);
        cacheUrl.searchParams.delete("requestId");
        // Store the URL in cache by prepending the body's hash
        cacheUrl.pathname = "/posts" + cacheUrl.pathname + hash;
        // Convert to a GET to be able to cache
        const cacheKey = new Request(cacheUrl.toString(), {
          headers: request.headers,
          method: "GET",
        });

        const cache = caches.default;
        // Find the cache key in the cache
        let response = await cache.match(cacheKey);
        // Otherwise, fetch response to POST request from origin
        if (!response) {
          response = await fetch(request);
          if(response.ok) {
            ctx.waitUntil(cache.put(cacheKey, response.clone()));
          }
        }
        return response;
      }
      return fetch(request);
    } catch (e) {
      return new Response("Error thrown " + e.message);
    }
  },
};
