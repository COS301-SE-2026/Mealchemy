"""Mealchemy recommendation engine entry point."""

# This is a place holder, minimla HTTP server that exists to keep Docker coatiner alive and pass health check, this will get replaced when we implement the engine. Docker hits http://localhost:8000/health to check health of Engine conatainer

import http.server
import json


class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path == "/health":
            body = json.dumps({"status": "UP"}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format: str, *args: object) -> None:
        pass  # suppress per-request access logs


def main() -> None:
    server = http.server.HTTPServer(("0.0.0.0", 8000), HealthHandler)
    print("Mealchemy engine starting on port 8000...")
    server.serve_forever()


if __name__ == "__main__":
    main()
