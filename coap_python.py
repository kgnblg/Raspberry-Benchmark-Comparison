from coapthon.client.helperclient import HelperClient

host = "192.168.1.56"
port = 5683
path = "?token=a&service=media&params=upload/1/0"
with open('home/pi/Desktop/images29.jpg','r') as f:
    payload = f.read()
client = HelperClient(server=(host, port))
gonder = payload
response = client.post(path, gonder, None)
print response.pretty_print()
client.stop()