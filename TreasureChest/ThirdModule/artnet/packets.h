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
 * packets.h
 * Datagram definitions for libartnet
 * Copyright (C) 2004-2005 Simon Newton
 */


#ifndef ARTNET_PACKETS_H
#define ARTNET_PACKETS_H

#include <sys/types.h>
#include <stdint.h>

#ifndef WIN32
#include <netinet/in.h>
#endif

#include "common.h"




#ifdef _MSC_VER
    #define PACKED
    #pragma pack(push,1)
#else
    #define PACKED __attribute__((packed))
#endif


enum { ARTNET_MAX_RDM_ADCOUNT = 32 };

enum { ARTNET_MAX_UID_COUNT = 200 };

// according to the rdm spec, this should be 278 bytes
// we'll set to 512 here, the firmware datagram is still bigger
enum { ARTNET_MAX_RDM_DATA = 512 };

enum { ARTNET_FIRMWARE_SIZE = 512 };

// Art-Net包中使用操作码：这里是早期版本，目前文档版本中有多个type没在枚举中。
enum artnet_packet_type_e {
  ARTNET_POLL = 0x2000,             //!< 这是一个ArtPoll包，没有其他数据被包含在这个UDP包中
  ARTNET_REPLY = 0x2100,            //!< 这是一个ArtPollReply包,包含设备状态信息
  ARTNET_DMX = 0x5000,              //!< 这是一ArtDmx数据包。它包含零起始码DMX512信息的单一的全集
  ARTNET_ADDRESS = 0x6000,          //!< 这是一个ArtAddress分组。它包含了节点远程编程的信息
  ARTNET_INPUT = 0x7000,            //!< 这是一个ArtInput数据包，它包含DMX输入的许可-禁止数据
  ARTNET_TODREQUEST = 0x8000,       //!< 这是一个ArtTodRequest包。它用于请求一个设备表(ToD)，来发现RDM
  ARTNET_TODDATA = 0x8100,          //!< 这是一个ArtTodData数据包。用于发送设备表ToD (Table of Devices)，以发现RDM
  ARTNET_TODCONTROL = 0x8200,       //!< 这是一个ArtTodControl包。用于发送'RDM发现控制消息'。
  ARTNET_RDM = 0x8300,              //!< 这是一个ArtRdm报文。用于发送所有‘非发现RDM消息’。
  ARTNET_VIDEOSTEUP = 0xa010,       //!< 这是一个ArtVideoSetup 数据包。包含实现扩展的视频功能的节点的视频画面设置信息
  ARTNET_VIDEOPALETTE = 0xa020,     //!< 这是一个ArtVideoPalette 数据包。包含实现扩展的视频功能的节点的调色板设置信息
  ARTNET_VIDEODATA = 0xa040,        //!< 这是一个ArtVideoData 数据包。包含实现扩展的视频功能的节点的显示数据
  ARTNET_MACMASTER = 0xf000,        //!< This packet is deprecated（用来编程节点的MAC地址，OEM设备类型和制造商ESTA代码。这是一个节点的出厂初始化。）
  ARTNET_MACSLAVE = 0xf100,         //!< This packet is deprecated.
  ARTNET_FIRMWAREMASTER = 0xf200,   //!< 这是一个 ArtFirmwareMaster 数据包。用于将新固件或固件扩展上传到节点
  ARTNET_FIRMWAREREPLY = 0xf300,    //!< 这是一个artfirmwareereply包。它由节点返回以确认收到ArtFirmwareMaster包或ArtFileTnMaster包。
  ARTNET_IPPROG = 0xf800,           //!< 这是一个ArtIpProg包。用于重新编程节点的IP地址和掩码
  ARTNET_IPREPLY = 0xf900,          //!< 这是一个ArtIpProgReply包。它由节点返回，以确认收到ArtIpProg包
  ARTNET_MEDIA = 0x9000,            //!< 这是一个ArtMedia包。它由媒体服务器进行单播，并由控制器进行操作
  ARTNET_MEDIAPATCH = 0x9200,       //!< 这是一个ArtMediaControl包。它由控制器进行单播，并由媒体服务器执行
  ARTNET_MEDIACONTROLREPLY = 0x9300 //!< 这是一个ArtMediaControlReply报文。它由媒体服务器进行单播，并由控制器进行操作
} PACKED;

typedef enum artnet_packet_type_e artnet_packet_type_t;

///The ArtPoll packet is used to discover the presence of other Controllers, Nodes and Media Servers.
///The ArtPoll packet is only sent by a Controller. Both Controllers and Nodes respond to the packet.
struct    artnet_poll_s {
  uint8_t  id[8];
  uint16_t opCode;                  //!< 操作码（OpCode）定义了再UDP包中紧随ArtPoll的数据的类型。 先传输低字节。
  uint8_t  verH;                    //!< Art-Net协议版本号高字节
  uint8_t  ver;                     //!< 版本号低字节。当前值为14，控制器应该忽略与节点的通讯当使用版本号低于14的协议。
  uint8_t  ttm;                     //!< talk to me
  uint8_t  pad;                     //!< priority：应发送的诊断消息的最低优先级
} PACKED;

typedef struct artnet_poll_s artnet_poll_t;

struct artnet_reply_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  ip[4];
  uint16_t port;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  subH;
  uint8_t  sub;
  uint8_t  oemH;
  uint8_t  oem;
  uint8_t  ubea;
  uint8_t  status;
  uint8_t  etsaman[2];
  uint8_t  shortname[ARTNET_SHORT_NAME_LENGTH];
  uint8_t  longname[ARTNET_LONG_NAME_LENGTH];
  uint8_t  nodereport[ARTNET_REPORT_LENGTH];
  uint8_t  numbportsH;
  uint8_t  numbports;
  uint8_t  porttypes[ARTNET_MAX_PORTS];
  uint8_t  goodinput[ARTNET_MAX_PORTS];
  uint8_t  goodoutput[ARTNET_MAX_PORTS];
  uint8_t  swin[ARTNET_MAX_PORTS];
  uint8_t  swout[ARTNET_MAX_PORTS];
  uint8_t  swvideo;
  uint8_t  swmacro;
  uint8_t  swremote;
  uint8_t  sp1;
  uint8_t  sp2;
  uint8_t  sp3;
  uint8_t  style;
  uint8_t  mac[ARTNET_MAC_SIZE];
  uint8_t  filler[32];
} PACKED;

typedef struct artnet_reply_s artnet_reply_t;

struct artnet_ipprog_s {
  uint8_t  id[8];
  uint16_t OpCode;
  uint8_t  ProVerH;
  uint8_t  ProVer;
  uint8_t  Filler1;
  uint8_t  Filler2;
  uint8_t  Command;
  uint8_t  Filler4;
  uint8_t  ProgIpHi;
  uint8_t  ProgIp2;
  uint8_t  ProgIp1;
  uint8_t  ProgIpLo;
  uint8_t  ProgSmHi;
  uint8_t  ProgSm2;
  uint8_t  ProgSm1;
  uint8_t  ProgSmLo;
  uint8_t  ProgPortHi;
  uint8_t  ProgPortLo;
  uint8_t  Spare1;
  uint8_t  Spare2;
  uint8_t  Spare3;
  uint8_t  Spare4;
  uint8_t  Spare5;
  uint8_t  Spare6;
  uint8_t  Spare7;
  uint8_t  Spare8;

} PACKED;

typedef struct artnet_ipprog_s artnet_ipprog_t;

struct artnet_ipprog_reply_s {
  uint8_t id[8];
  uint16_t  OpCode;
  uint8_t  ProVerH;
  uint8_t  ProVer;
  uint8_t  Filler1;
  uint8_t  Filler2;
  uint8_t  Filler3;
  uint8_t  Filler4;
  uint8_t  ProgIpHi;
  uint8_t  ProgIp2;
  uint8_t  ProgIp1;
  uint8_t  ProgIpLo;
  uint8_t  ProgSmHi;
  uint8_t  ProgSm2;
  uint8_t  ProgSm1;
  uint8_t  ProgSmLo;
  uint8_t  ProgPortHi;
  uint8_t  ProgPortLo;
  uint8_t  Spare1;
  uint8_t  Spare2;
  uint8_t  Spare3;
  uint8_t  Spare4;
  uint8_t  Spare5;
  uint8_t  Spare6;
  uint8_t  Spare7;
  uint8_t  Spare8;
} PACKED;

typedef struct artnet_ipprog_reply_s artnet_ipprog_reply_t;


struct artnet_address_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  shortname[ARTNET_SHORT_NAME_LENGTH];
  uint8_t  longname[ARTNET_LONG_NAME_LENGTH];
  uint8_t  swin[ARTNET_MAX_PORTS];
  uint8_t  swout[ARTNET_MAX_PORTS];
  uint8_t  subnet;
  uint8_t  swvideo;
  uint8_t  command;
} PACKED;

typedef struct artnet_address_s artnet_address_t;


struct artnet_dmx_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  sequence;
  uint8_t  physical;
  uint16_t  universe;
  uint8_t  lengthHi;
  uint8_t  length;
  uint8_t  data[ARTNET_DMX_LENGTH];
} PACKED;

typedef struct artnet_dmx_s artnet_dmx_t;


struct artnet_input_s {
  uint8_t id[8];
  uint16_t  opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  numbportsH;
  uint8_t  numbports;
  uint8_t  input[ARTNET_MAX_PORTS];
} PACKED;

typedef struct artnet_input_s artnet_input_t;


struct artnet_todrequest_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  spare1;
  uint8_t  spare2;
  uint8_t  spare3;
  uint8_t  spare4;
  uint8_t  spare5;
  uint8_t  spare6;
  uint8_t  spare7;
  uint8_t  spare8;
  uint8_t  command;
  uint8_t  adCount;
  uint8_t  address[ARTNET_MAX_RDM_ADCOUNT];
} PACKED;

typedef struct artnet_todrequest_s artnet_todrequest_t;



struct artnet_toddata_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  rdmVer;
  uint8_t  port;
  uint8_t  spare1;
  uint8_t  spare2;
  uint8_t  spare3;
  uint8_t  spare4;
  uint8_t  spare5;
  uint8_t  spare6;
  uint8_t  spare7;
  uint8_t  spare8;
  uint8_t  cmdRes;
  uint8_t  address;
  uint8_t  uidTotalHi;
  uint8_t  uidTotal;
  uint8_t  blockCount;
  uint8_t  uidCount;
  uint8_t  tod[ARTNET_MAX_UID_COUNT][ARTNET_RDM_UID_WIDTH];
} PACKED;

typedef struct artnet_toddata_s artnet_toddata_t;

struct artnet_firmware_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  type;
  uint8_t  blockId;
  uint8_t  length[4];
  uint8_t  spare[20];
  uint16_t  data[ARTNET_FIRMWARE_SIZE ];
} PACKED;

typedef struct artnet_firmware_s artnet_firmware_t;

struct artnet_todcontrol_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  spare1;
  uint8_t  spare2;
  uint8_t  spare3;
  uint8_t  spare4;
  uint8_t  spare5;
  uint8_t  spare6;
  uint8_t  spare7;
  uint8_t  spare8;
  uint8_t  cmd;
  uint8_t  address;
} PACKED;


typedef struct artnet_todcontrol_s artnet_todcontrol_t;



struct artnet_rdm_s {
  uint8_t id[8];
  uint16_t  opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  rdmVer;
  uint8_t  filler2;
  uint8_t  spare1;
  uint8_t  spare2;
  uint8_t  spare3;
  uint8_t  spare4;
  uint8_t  spare5;
  uint8_t  spare6;
  uint8_t  spare7;
  uint8_t  spare8;
  uint8_t  cmd;
  uint8_t  address;
  uint8_t  data[ARTNET_MAX_RDM_DATA];
} PACKED;


typedef struct artnet_rdm_s artnet_rdm_t;


struct artnet_firmware_reply_s {
  uint8_t  id[8];
  uint16_t opCode;
  uint8_t  verH;
  uint8_t  ver;
  uint8_t  filler1;
  uint8_t  filler2;
  uint8_t  type;
  uint8_t  spare[21];
} PACKED;

typedef struct artnet_firmware_reply_s artnet_firmware_reply_t;



// union of all artnet packets
typedef union {
  artnet_poll_t ap;
  artnet_reply_t ar;
  artnet_ipprog_t aip;
  artnet_address_t addr;
  artnet_dmx_t admx;
  artnet_input_t ainput;
  artnet_todrequest_t todreq;
  artnet_toddata_t toddata;
  artnet_firmware_t firmware;
  artnet_firmware_reply_t firmwarer;
  artnet_todcontrol_t todcontrol;
  artnet_rdm_t rdm;
} artnet_packet_union_t;


// a packet, containing data, length, type and a src/dst address
typedef struct {
  int length;
  struct in_addr from;
  struct in_addr to;
  artnet_packet_type_t type;
  artnet_packet_union_t data;
} artnet_packet_t;

typedef artnet_packet_t *artnet_packet;


#ifdef _MSC_VER
    #pragma pack(pop)
#endif

#undef PACKED


#endif
