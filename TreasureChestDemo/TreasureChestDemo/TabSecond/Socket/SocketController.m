//
//  SocketController.m
//  TreasureChest
//
//  Created by imvt on 2022/3/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "SocketController.h"
#import "SocketServer.h"
#import "SocketClient.h"

///test
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

#include "net/if.h"
#include "arpa/inet.h"
#include <sys/socket.h> // socket before net/if.h for mac
#include <net/if.h>
#include <sys/ioctl.h>
///test

@interface SocketController ()

@property(nonatomic, weak)IBOutlet UIButton *serverMsgBtn;
@property(nonatomic, weak)IBOutlet UITextField *serverField;
@property(nonatomic, weak)IBOutlet UILabel *serverLabel;

@property(nonatomic, weak)IBOutlet UIButton *clientMsgBtn;
@property(nonatomic, weak)IBOutlet UITextField *clientField;
@property(nonatomic, weak)IBOutlet UILabel *clientLabel;

@property(nonatomic, weak)IBOutlet UIButton *startServerBtn;
@property(nonatomic, weak)IBOutlet UIButton *startClientBtn;

@property(nonatomic, strong)SocketServer *server;
@property(nonatomic, strong)SocketClient *client;

@end

@implementation SocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
    self.server = [[SocketServer alloc]init];
    self.client = [[SocketClient alloc]init];
    [self test];
}

- (void)test {
    struct sockaddr_in *addr;
    struct ifreq ifr;
    char*address;
    int sockfd;

    char *name = "eth0";
    if( strlen(name) >= IFNAMSIZ)
        printf("device name is error.\n");
        
    strcpy( ifr.ifr_name, name);
        
    sockfd = socket(AF_INET,SOCK_DGRAM,0);

    //get inet addr
    if( ioctl( sockfd, SIOCGIFADDR, &ifr) == -1)
        printf("ioctl error.\n");

    addr = (struct sockaddr_in *)&(ifr.ifr_addr);
    address = inet_ntoa(addr->sin_addr);

    printf("inet addr: %s\n",address);
    
    //get Mask
    if( ioctl( sockfd, SIOCGIFNETMASK, &ifr) == -1)
        printf("ioctl error.\n");

    addr = (struct sockaddr_in *)&ifr.ifr_addr;
    address = inet_ntoa(addr->sin_addr);

    printf("Mask: %s\n",address);

    //get HWaddr
    u_int8_t hd[6];
//    if(ioctl(sockfd, SIOCGIFHWADDR, &ifr) == -1)
//        printf("hwaddr error.\n"), exit(0);

//    memcpy( hd, ifr.ifr_hwaddr.sa_data, sizeof(hd));
    printf("HWaddr: %02X:%02X:%02X:%02X:%02X:%02X\n", hd[0], hd[1], hd[2], hd[3], hd[4], hd[5]);
}

#pragma mark - < event >
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)startServerEvent:(UIButton *)button {
    [self.server startServer];
}

- (IBAction)startClientEvent:(UIButton *)button {
    [self.client startClient];
}

- (IBAction)sendServerMsgEvent:(UIButton *)button {
    [self.server sendMessage:self.serverField.text];
}

- (IBAction)startClientMsgEvent:(UIButton *)button {
    [self.client sendMessage:self.clientField.text];
}

#pragma mark - < init >
- (void)setupSubViews {

}


@end
