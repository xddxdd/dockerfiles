#define _GNU_SOURCE 1

#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <linux/rtnetlink.h>
#include <string.h>

#define BUF_SIZE 256
#define IPV4_ADDR_LEN 4
#define IPV6_ADDR_LEN 16
#define IPV6_INT32_SEGS (IPV6_ADDR_LEN / sizeof(uint32_t))

struct ip_blk {
    uint32_t af;

    union {
        char addr[IPV6_ADDR_LEN];
        uint32_t addr_v4;
        uint32_t addr_v6[IPV6_INT32_SEGS];
    };
};

static int if_get_index() {
    char buf[] = "/sys/class/net/eth0/ifindex";
    int len;
    int fd = open(buf, O_RDONLY);
    len = read(fd, buf, sizeof(buf));
    buf[len] = '\0';
    close(fd);
    return atoi(buf);
}

static void if_addr(const uint8_t af, const char* addr) {
    struct {
        struct nlmsghdr  nh;
        struct ifaddrmsg msg;
        char             attrbuf[BUF_SIZE];
    } req;

    struct rtattr *rta;
    int fd;
    if (0 > (fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE))) abort();

    /* https://stackoverflow.com/questions/14369043/add-and-remove-ip-addresses-to-an-interface-using-ioctl-or-netlink */
    memset(&req, 0, sizeof(req));
    req.nh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrmsg));
    req.nh.nlmsg_flags = NLM_F_CREATE | NLM_F_EXCL | NLM_F_REQUEST | NLM_F_ACK;
    req.nh.nlmsg_type = RTM_NEWADDR;
    req.msg.ifa_family = af;
    req.msg.ifa_prefixlen = (af == AF_INET) ? 32 : 128;
    req.msg.ifa_scope = 0;
    req.msg.ifa_index = if_get_index();
    rta = (struct rtattr *) (((char *) &req) + NLMSG_ALIGN(req.nh.nlmsg_len));
    rta->rta_type = IFA_LOCAL;
    rta->rta_len = RTA_LENGTH(af == AF_INET6 ? IPV6_ADDR_LEN : IPV4_ADDR_LEN);
    req.nh.nlmsg_len = NLMSG_ALIGN(req.nh.nlmsg_len) + RTA_LENGTH(af == AF_INET6 ? IPV6_ADDR_LEN : IPV4_ADDR_LEN);
    memcpy(RTA_DATA(rta), addr, af == AF_INET6 ? IPV6_ADDR_LEN : IPV4_ADDR_LEN);

    if (0 > send(fd, &req, req.nh.nlmsg_len, 0)) abort();

    close(fd);
}

int main(int argc, char* argv[]) {
    uint32_t ip_blks_len = argc - 1;
    struct ip_blk *ip_blks = malloc(sizeof(struct ip_blk) * ip_blks_len);

    for (int i = 1; i < argc; i++) {
        ip_blks[i - 1].af = (NULL != strstr(argv[i], ":")) ? AF_INET6 : AF_INET;

        if(0 == inet_pton(ip_blks[i - 1].af,
                          argv[i],
                          ip_blks[i - 1].addr)) abort();

        if_addr(ip_blks[i - 1].af, ip_blks[i - 1].addr);
    }

    free(ip_blks);

    while(1) {
        pause();
    }

    return 0;
}
