import argparse
class MakeComposeYml:
    def __init__(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("first", help = "First IP of the network")
        parser.add_argument("target", help = "Target IP of the network")
        self.args = parser.parse_args()
        ips = self.calculateNetwork(self.args.first, self.args.target)
        self.f = open('docker-compose.yml', 'w')
        self.writeHeader()
        for i, ip in enumerate(ips):
            self.writeContainer(i + 1, ip)
        self.writeFooter()
        self.f.close()
    
    def calculateNetwork(self, first, target):
        first_split = first.split('.')
        target_split = target.split('.')
        if first_split[0:3] != target_split[0:3]:
            raise ValueError("First and target not in same subnet")
        if int(first_split[3]) >= int(target_split[3]):
            raise ValueError("First IP comes after target IP")
        ips = []
        new_ip = first_split
        for last_space in range(int(first_split[3]), int(target_split[3]) + 1):
            new_ip[3] = str(last_space)
            ips.append('.'.join(new_ip))
        return ips
    
    def writeHeader(self):
        header = 'version: "2.1"\nservices:'
        self.f.write(header)

    def writeContainer(self, i, ip):
        body = '''
  routing%i:
    image: xddxdd/route-next:latest
    container_name: routing%i
    restart: always
    cap_add:
      - NET_ADMIN
    environment:
      - TARGET_IP=%s
    networks:
      routing:
        ipv4_address: %s
'''
        self.f.write(body % (i, i, self.args.target, ip))
    
    def writeFooter(self):
        footer = '''
networks:
  routing:
    driver: bridge
    ipam:
      driver: default
      config:
      - subnet: %s.0/24
        gateway: %s.1
'''
        subnet = '.'.join(self.args.first.split('.')[0:3])
        self.f.write(footer % (subnet, subnet))

make = MakeComposeYml()