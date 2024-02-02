#include "icam_message.h"

#include <string.h>

static unsigned int unpack_u32(const unsigned char *buf)
{
    return ((buf[0] << 24)| (buf[1] << 16) | (buf[2] << 8) |(buf[3]));
}

static unsigned short unpack_u16(const unsigned char *buf)
{
    return ((buf[0] << 8)| (buf[1]));
}

static unsigned char* pack_u32(unsigned char *buf, uint32_t value)
{
    *buf++ = value >> 24;
    *buf++ = value >> 16;
    *buf++ = value >> 8;
    *buf++ = value;
    return buf;
}

static unsigned char* pack_u16(unsigned char *buf, uint32_t value)
{
    *buf++ = value >> 8;
    *buf++ = value;
    return buf;
}

unsigned int icam_message_decode_header(const char *data, unsigned len, struct icam_msg_header *header)
{
    assert(data != NULL);
    assert(header != NULL);
    assert(len >= kPacketHeaderSize);
    
    unsigned char *ptr = (unsigned char*)data;
    header->payload_size = unpack_u16(ptr);
    ptr += 2;
    
    header->channel = unpack_u16(ptr);
    ptr += 2;
    
    return kPacketHeaderSize;
}

unsigned int icam_message_decode(const char *data, unsigned int len, struct icam_msg *message)
{
    assert(data != NULL);
    assert(message != NULL);
    assert(len > 0);

    if (len < kPacketHeaderSize) {
        return 0;
    }

    unsigned char *ptr = (unsigned char*)data;
    message->header.payload_size = unpack_u16(ptr);
    if (len < message->header.payload_size + kPacketHeaderSize) {
        return 0;
    }
    ptr += 2;

    message->header.channel = unpack_u16(ptr);
    ptr += 2;

    if (message->header.channel != 0) {
        message->transport.data = ptr;
        message->transport.len = message->header.payload_size;
        return message->header.payload_size + kPacketHeaderSize;
    }

    message->type = unpack_u16(ptr);
    ptr += 2;
    // body
    if (message->type == kPacketTypeNewChannel) {
        // | id | port |
        message->conn.channel_id = unpack_u16((ptr));
        ptr += 2;

        message->conn.port = unpack_u16((ptr));
        ptr += 2;
    } else if (message->type == kPacketTypeDeleteChannel) {
        // | id |
        message->conn.channel_id = unpack_u16((ptr));
        ptr += 2;
    } else if (message->type == kPacketTypeLinkUp || message->type == kPacketTypeLinkDown) {
        // | id |
        message->conn.channel_id = unpack_u16((ptr));
        ptr += 2;
    } else if (message->type == kPacketTypeStreamCtrl) {
        // | id |
        message->stream_ctrl.cmd = *ptr;
        ptr += 1;
    }
    
    return message->header.payload_size + kPacketHeaderSize;
}

unsigned int icam_message_encode_ping(unsigned char * data, unsigned int len)
{
    if (len < kPacketHeaderSize + 2) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 2);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypePing);
    
    return kPacketHeaderSize + 2;
}

unsigned int icam_message_encode_pong(unsigned char * data, unsigned int len)
{
    if (len < kPacketHeaderSize + 2) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 2);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypePong);

    return kPacketHeaderSize + 2;
}

unsigned int icam_message_encode_setup(unsigned char * data, unsigned int len, unsigned char stream)
{
    if (len < kPacketHeaderSize + 3) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 2);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeSetup);
    data[0] = stream;
    return kPacketHeaderSize + 3;
}

unsigned int icam_message_encode_stream_ctrl(unsigned char * data, unsigned int len, unsigned char cmd)
{
    if (len < kPacketHeaderSize + 3) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 3);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeStreamCtrl);
    data[0] = cmd;
    return kPacketHeaderSize + 3;
}

unsigned int icam_message_encode_new_channel(unsigned char *data, unsigned int len, unsigned int channel, unsigned short port)
{
    if (len < kPacketHeaderSize + 6) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 6);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeNewChannel);
    data = pack_u16(data, channel);
    data = pack_u16(data, port);
    
    return kPacketHeaderSize + 6;
}

unsigned int icam_message_encode_delete_channel(unsigned char *data, unsigned int len, unsigned int channel)
{
    if (len < kPacketHeaderSize + 4) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 4);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeDeleteChannel);
    data = pack_u16(data, channel);
    
    return kPacketHeaderSize + 4;
}

unsigned int icam_message_encode_channel_linkup(unsigned char *data, unsigned int len, unsigned int channel)
{
    if (len < kPacketHeaderSize + 4) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 4);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeLinkUp);
    data = pack_u16(data, channel);
    
    return kPacketHeaderSize + 4;
}

unsigned int icam_message_encode_channel_linkdown(unsigned char *data, unsigned int len, unsigned int channel)
{
    if (len < kPacketHeaderSize + 4) {
        return 0;
    }
    
    icam_message_encode_header(data, len, 0, 4);
    data += kPacketHeaderSize;
    
    data = pack_u16(data, kPacketTypeLinkDown);
    data = pack_u16(data, channel);
    
    return kPacketHeaderSize + 4;
}

unsigned int icam_message_encode_header(unsigned char * data, unsigned int len, unsigned int channel, unsigned short payload_size)
{
    if (len < 4) {
        return 0;
    }
    
    data = pack_u16(data, payload_size);   // size
    data = pack_u16(data, channel);   // channel
    
    return 4;
}
