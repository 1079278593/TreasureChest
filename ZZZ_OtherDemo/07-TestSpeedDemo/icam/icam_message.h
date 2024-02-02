#ifndef _ICAM_MESSAGE_H_
#define _ICAM_MESSAGE_H_

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif /* End of #ifdef __cplusplus */

#include <assert.h>

#define kPacketHeaderSize   (4)

enum icam_msg_type {
    kPacketTypePing,
    kPacketTypePong,
    kPacketTypeSetup,
    kPacketTypeNewChannel,
    kPacketTypeDeleteChannel,
    kPacketTypeLinkUp,
    kPacketTypeLinkDown,
    kPacketTypeStreamCtrl,
};
    
struct icam_msg_header {
    // header
    unsigned short payload_size;
    unsigned short channel;
};

struct icam_msg {
    struct icam_msg_header header;
    // body
    unsigned short type;
    union {
        struct {
            unsigned short channel_id;
            unsigned short port;
        } conn;

        struct {
            const void *data;
            unsigned int len;
        } transport;
        
        struct {
            unsigned char stream;   // 1: stream, 2: command
        } setup;
        
        struct {
            unsigned char cmd;   // 1: start, 0: stop
        } stream_ctrl;
    };
};

unsigned int icam_message_decode_header(const char *ptr, unsigned len, struct icam_msg_header *header);
unsigned int icam_message_decode(const char *ptr, unsigned int len, struct icam_msg *message);

unsigned int icam_message_encode_ping(unsigned char * data, unsigned int len);
unsigned int icam_message_encode_pong(unsigned char * data, unsigned int len);
unsigned int icam_message_encode_setup(unsigned char * data, unsigned int len, unsigned char stream);
unsigned int icam_message_encode_stream_ctrl(unsigned char * data, unsigned int len, unsigned char cmd);

unsigned int icam_message_encode_new_channel(unsigned char *data, unsigned int len, unsigned int channel, unsigned short port);
unsigned int icam_message_encode_delete_channel(unsigned char *data, unsigned int len, unsigned int channel);
    
unsigned int icam_message_encode_channel_linkup(unsigned char *data, unsigned int len, unsigned int channel);
unsigned int icam_message_encode_channel_linkdown(unsigned char *data, unsigned int len, unsigned int channel);

unsigned int icam_message_encode_header(unsigned char * data, unsigned int len, unsigned int channel, unsigned short payload_size);
    

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif /* End of #ifdef __cplusplus */

#endif
