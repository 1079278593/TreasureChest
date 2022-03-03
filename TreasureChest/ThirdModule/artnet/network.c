/*
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * network.c
 * Network code for libartnet
 * Copyright (C) 2004-2007 Simon Newton
 *
 */

#include <errno.h>

#if !defined(WIN32) && !defined(_MSC_VER)
#include <sys/socket.h> // socket before net/if.h for mac
#include <net/if.h>
#include <sys/ioctl.h>
#else
typedef int socklen_t;
#include <winsock2.h>
#include <lm.h>
#include <iphlpapi.h>
#endif

// Visual Studio specific things, that may not be needed for MinGW/MSYS
#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#else
#include <unistd.h>
#endif

#include "private.h"

#ifdef HAVE_GETIFADDRS
 #ifdef HAVE_LINUX_IF_PACKET_H
   #define USE_GETIFADDRS
 #endif
#endif

#ifdef USE_GETIFADDRS
  #include <ifaddrs.h>
  #include <linux/types.h> // required by if_packet
  #include <linux/if_packet.h>
#endif


enum { INITIAL_IFACE_COUNT = 10 };
enum { IFACE_COUNT_INC = 5 };
enum { IFNAME_SIZE = 32 }; // 32 sounds a reasonable size

typedef struct iface_s {
  struct sockaddr_in ip_addr;
  struct sockaddr_in bcast_addr;
  int8_t hw_addr[ARTNET_MAC_SIZE];
  char   if_name[IFNAME_SIZE];
  struct iface_s *next;
} iface_t;

unsigned long LOOPBACK_IP = 0x7F000001;


/*
 * Free memory used by the iface's list
 * @param head a pointer to the head of the list
 */
static void free_ifaces(iface_t *head) {
  iface_t *ift, *ift_next;

  for (ift = head; ift != NULL; ift = ift_next) {
    ift_next = ift->next;
    free(ift);
  }
}


/*
 * Add a new interface to an interface list
 * @param head pointer to the head of the list
 * @param tail pointer to the end of the list
 * @return a new iface_t or void
 */
static iface_t *new_iface(iface_t **head, iface_t **tail) {
  iface_t *iface = (iface_t*) calloc(1, sizeof(iface_t));

  if (!iface) {
    artnet_error("%s: calloc error %s" , __FUNCTION__, strerror(errno));
    return NULL;
  }
  memset(iface, 0, sizeof(iface_t));

  if (!*head) {
    *head = *tail = iface;
  } else {
    (*tail)->next = iface;
    *tail = iface;
  }
  return iface;
}

char** breakChar(char *str, char *delims) {
    int col = 4, row = 3;
    char **result;
    result = (char **)malloc(sizeof(char*)*col);
    for(int i=0;i<col;i++) {
        result[i]=(char*)malloc(sizeof(char)*row);
    }
    
    char *target = NULL;
    int i = 0;
    
    target = strtok( str, delims );
    while( target != NULL ) {
        printf( "result is \"%s\"\n", target );
        strcpy(result[i], target);
        i++;
        target = strtok( NULL, delims );
    }
    return result;
}


/*
 * Set if_head to point to a list of iface_t structures which represent the
 * interfaces on this machine
 * @param ift_head the address of the pointer to the head of the list
 */
static int get_ifaces(iface_t **if_head) {
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    struct ifreq *ifr, ifrcopy;
    struct sockaddr_in *sin;
    int flags;
    char buf[BUFFERSIZE], *ptr,lastname[IFNAMSIZ], *cptr;
    iface_t *if_tail, *iface;
    int ret = ARTNET_EOK;
    int sd;

    *if_head = if_tail = NULL;

    // create socket to get iface config：创建一个socket来获取iface配置
    sd = socket(PF_INET, SOCK_DGRAM, 0);

    if (sd < 0) {
        artnet_error("%s : Could not create socket %s", __FUNCTION__, strerror(errno));
        ret = ARTNET_ENET;
        goto e_return;
    }

    // first use ioctl to get a listing of interfaces：首先使用ioctl获取接口列表
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buf;
    if (ioctl(sd, SIOCGIFCONF, &ifc) >= 0){
        for (ptr = buf; ptr < buf + ifc.ifc_len; ){
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            
            ifrcopy = *ifr;
            int tmpFlag = ioctl(sd, SIOCGIFFLAGS, &ifrcopy);
            if (tmpFlag < 0) {
                printf("get flag fail");
            }
            
            printf("ip:%s\n",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr));
            
            flags = ifrcopy.ifr_flags;
            if ((flags & IFF_UP) == 0) continue;
            
            iface = new_iface(if_head, &if_tail);
            if (!iface)
              goto e_free_list;
            
            sin = (struct sockaddr_in *) &ifr->ifr_addr;
            iface->ip_addr.sin_addr = sin->sin_addr;
            
            // fetch bcast address：获取广播地址的地址
            if (flags & IFF_BROADCAST) {
                if (ioctl(sd, SIOCGIFBRDADDR, &ifrcopy) < 0) {
                    artnet_error("%s : ioctl error %s" , __FUNCTION__, strerror(errno));
                    ret = ARTNET_ENET;
                    goto e_free_list;
                }

                sin = (struct sockaddr_in *) &ifrcopy.ifr_broadaddr;
                iface->bcast_addr.sin_addr = sin->sin_addr;
            }
            
//            printf("ip:%s\n",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr));
//            NSString *ip = [NSString stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
//            [ips addObject:ip];
        }
    }
    
//  free(buf);
  close(sd);
  return ARTNET_EOK;

e_free_list:
  free_ifaces(*if_head);
e_free:
  free(buf);
  close(sd);
e_return:
  return ret;
}


/*
 * Scan for interfaces, and work out which one the user wanted to use.
 */
int artnet_net_init(node in_node, const char *preferred_ip) {
    iface_t *ift, *ift_head = NULL;
    struct in_addr wanted_ip;

    int found = FALSE;
    int i;
    int ret = ARTNET_EOK;

    if ((ret = get_ifaces(&ift_head)))
        goto e_return;

    if (in_node->state.verbose) {
        printf("#### INTERFACES FOUND ####\n");
        for (ift = ift_head; ift != NULL; ift = ift->next) {
            printf("IP: %s\n", inet_ntoa(ift->ip_addr.sin_addr));
            printf("  bcast: %s\n" , inet_ntoa(ift->bcast_addr.sin_addr));
            printf("  hwaddr: ");
            for (i = 0; i < ARTNET_MAC_SIZE; i++) {
                if (i)
                    printf(":");
                printf("%02x", (uint8_t) ift->hw_addr[i]);
            }
            printf("\n");
        }
        printf("#########################\n");
    }

    if (preferred_ip) {
        // search through list of interfaces for one with the correct address
        ret = artnet_net_inet_aton(preferred_ip, &wanted_ip);//注意大段和小段问题
        if (ret)
            goto e_cleanup;

        for (ift = ift_head; ift != NULL; ift = ift->next) {
            char *member_ip = inet_ntoa(ift->ip_addr.sin_addr);
            if (strstr(member_ip, "127.0.0") != NULL) {
                continue;
            }
            if (ift->ip_addr.sin_addr.s_addr == wanted_ip.s_addr) {
                found = TRUE;
            }
            
            char originIP[20];
            memcpy(originIP, preferred_ip, sizeof(char)*20);
            char delims[] = ".";
            
            int similarCount = 0;
            char **originArr = breakChar(originIP, delims);
            char **memeberArr = breakChar(member_ip, delims);
            for (int i = 0; i<4; i++) {
                if (strcmp(originArr[i], memeberArr[i]) == 0) {
                    similarCount++;
                }
            }
            if (similarCount >= 2) {
                found = TRUE;
            }
            
            if (found) {
                in_node->state.ip_addr = ift->ip_addr.sin_addr;
                in_node->state.bcast_addr = ift->bcast_addr.sin_addr;
                memcpy(&in_node->state.hw_addr, &ift->hw_addr, ARTNET_MAC_SIZE);
                break;
            }
            
        }
        if (!found) {
            printf("Cannot find ip %s", preferred_ip);
            ret = ARTNET_ENET;
            goto e_cleanup;
        }
    } else {
        if (ift_head) {
            // pick first address
            // copy ip address, bcast address and hardware address
            in_node->state.ip_addr = ift_head->ip_addr.sin_addr;
            in_node->state.bcast_addr = ift_head->bcast_addr.sin_addr;
            memcpy(&in_node->state.hw_addr, &ift_head->hw_addr, ARTNET_MAC_SIZE);
        } else {
            printf("No interfaces found!");
            ret = ARTNET_ENET;
        }
    }

e_cleanup:
  free_ifaces(ift_head);
e_return :
  return ret;
}


/*
 * Start listening on the socket
 */
int artnet_net_start(node n) {
  artnet_socket_t sock;
  struct sockaddr_in servAddr;
  int true_flag = TRUE;
  node tmp;

  // only attempt to bind if we are the group master
  if (n->peering.master == TRUE) {

    // create socket
    sock = socket(PF_INET, SOCK_DGRAM, 0);

    if (sock == INVALID_SOCKET) {
      artnet_error("Could not create socket %s", artnet_net_last_error());
      return ARTNET_ENET;
    }

    memset(&servAddr, 0x00, sizeof(servAddr));
    servAddr.sin_family = AF_INET;
    servAddr.sin_port = htons(ARTNET_PORT);
    servAddr.sin_addr.s_addr = htonl(INADDR_ANY);

    if (n->state.verbose)
      printf("Binding to %s \n", inet_ntoa(servAddr.sin_addr));

    // allow bcasting
    if (setsockopt(sock,
                   SOL_SOCKET,
                   SO_BROADCAST,
                   (char*) &true_flag, // char* for win32
                   sizeof(int)) == -1) {
      artnet_error("Failed to bind to socket %s", artnet_net_last_error());
      artnet_net_close(sock);
      return ARTNET_ENET;
    }

      // allow reusing 6454 port _
    if (setsockopt(sock,
                 SOL_SOCKET,
                 SO_REUSEPORT,
                 (char*) &true_flag, // char* for win32
                 sizeof(int)) == -1) {
     artnet_error("Failed to bind to socket %s", artnet_net_last_error());
     artnet_net_close(sock);
     return ARTNET_ENET;
    }

    if (n->state.verbose)
      printf("Binding to %s \n", inet_ntoa(servAddr.sin_addr));

    // bind sockets
    if (bind(sock, (SA *) &servAddr, sizeof(servAddr)) == -1) {
      artnet_error("Failed to bind to socket %s", artnet_net_last_error());
      artnet_net_close(sock);
      return ARTNET_ENET;
    }


    n->sd = sock;
    // Propagate the socket to all our peers: 将这个套接字传播到所有的对等端
    for (tmp = n->peering.peer; tmp && tmp != n; tmp = tmp->peering.peer)
      tmp->sd = sock;
  }
  return ARTNET_EOK;
}


/*
 * Receive a packet.
 */
int artnet_net_recv(node n, artnet_packet p, int delay) {
  ssize_t len;
  struct sockaddr_in cliAddr;
  socklen_t cliLen = sizeof(cliAddr);
  fd_set rset;
  struct timeval tv;
  int maxfdp1 = n->sd + 1;

  FD_ZERO(&rset);
  FD_SET((unsigned int) n->sd, &rset);

  tv.tv_usec = 0;
  tv.tv_sec = delay;
  p->length = 0;

  switch (select(maxfdp1, &rset, NULL, NULL, &tv)) {
    case 0:
      // timeout
      return RECV_NO_DATA;
      break;
    case -1:
      if ( errno != EINTR) {
        artnet_error("Select error %s", artnet_net_last_error());
        return ARTNET_ENET;
      }
      return ARTNET_EOK;
      break;
    default:
      break;
  }

  // need a check here for the amount of data read
  // should prob allow an extra byte after data, and pass the size as sizeof(Data) +1
  // then check the size read and if equal to size(data)+1 we have an error
  len = recvfrom(n->sd,
                 (char*) &(p->data), // char* for win32
                 sizeof(p->data),
                 0,
                 (SA*) &cliAddr,
                 &cliLen);
  if (len < 0) {
    artnet_error("Recvfrom error %s", artnet_net_last_error());
    return ARTNET_ENET;
  }

  if (cliAddr.sin_addr.s_addr == n->state.ip_addr.s_addr ||
      ntohl(cliAddr.sin_addr.s_addr) == LOOPBACK_IP) {
    p->length = 0;
    return ARTNET_EOK;
  }

  p->length = len;
  memcpy(&(p->from), &cliAddr.sin_addr, sizeof(struct in_addr));
  // should set to in here if we need it
  return ARTNET_EOK;
}


/*
 * Send a packet.
 */
int artnet_net_send(node n, artnet_packet p) {
  struct sockaddr_in addr;
  int ret;

  if (n->state.mode != ARTNET_ON)
    return ARTNET_EACTION;

  addr.sin_family = AF_INET;
  addr.sin_port = htons(ARTNET_PORT);
  addr.sin_addr = p->to;
  p->from = n->state.ip_addr;

  if (n->state.verbose)
    printf("sending to %s\n" , inet_ntoa(addr.sin_addr));

  ret = sendto(n->sd,
               (char*) &p->data, // char* required for win32
               p->length,
               0,
               (SA*) &addr,
               sizeof(addr));
  if (ret == -1) {
    artnet_error("Sendto failed: %s", artnet_net_last_error());
    n->state.report_code = ARTNET_RCUDPFAIL;
    return ARTNET_ENET;

  } else if (p->length != ret) {
    artnet_error("failed to send full datagram");
    n->state.report_code = ARTNET_RCSOCKETWR1;
    return ARTNET_ENET;
  }

  if (n->callbacks.send.fh) {
    get_type(p);
    n->callbacks.send.fh(n, p, n->callbacks.send.data);
  }
  return ARTNET_EOK;
}


int artnet_net_set_fdset(node n, fd_set *fdset) {
  FD_SET((unsigned int) n->sd, fdset);
  return ARTNET_EOK;
}


/*
 * Close a socket
 */
int artnet_net_close(artnet_socket_t sock) {
    if (close(sock)) {
      artnet_error(artnet_net_last_error());
      return ARTNET_ENET;
    }
    return ARTNET_EOK;
}


/*
 * Convert a string to an in_addr
 */
int artnet_net_inet_aton(const char *ip_address, struct in_addr *address) {
#ifdef HAVE_INET_ATON
  if (!inet_aton(ip_address, address)) {
#else
  in_addr_t *addr = (in_addr_t*) address;
  if ((*addr = inet_addr(ip_address)) == INADDR_NONE &&
      strcmp(ip_address, "255.255.255.255")) {
#endif
    artnet_error("IP conversion from %s failed", ip_address);
    return ARTNET_EARG;
  }
  return ARTNET_EOK;
}

const char *artnet_net_last_error(void) {
    return strerror(errno);
}
