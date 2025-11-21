environment = "test"
resource_group_name="rg-signal-example"
signalr_name = "signalr-test-example"
allowed_origins = ["http://localhost:4200"]
public_network_access_enabled = false

network_interface_signalr = "nic-signalr-test-example"
pv_svc_connection_signalr="pe-signalr-test-example"
pv_endpoint_static_ip="10.0.1.12"
pv_endpoint_name = "pe-signalr-test-example"

tags = {
  environment = "test"
  project     = "signalr-example"
}