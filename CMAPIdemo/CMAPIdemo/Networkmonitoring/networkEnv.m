//
//  networkEnv.m
//  testipv6
//
//  Created by Eric Tang on 2017/9/22.
//  Copyright © 2017年 Cifernet, Inc. All rights reserved.
//

#import "networkEnv.h"
#import <arpa/inet.h>

@interface networkEnv ()
- (bool) _canConnectWithPF:(int) pf
                      addr:(struct sockaddr *)addr
                   addrlen:(socklen_t)addrlen;
- (bool) _checkIPv4;
- (bool) _checkIPv6;
@end

@implementation networkEnv

- (bool) _canConnectWithPF:(int)pf addr:(struct sockaddr *)addr addrlen:(socklen_t)addrlen {
  int rtCode;
  bool canConnect = false;
  int sockfd = socket (pf, SOCK_DGRAM, IPPROTO_UDP);
  if (sockfd <  0) return false;
  do {
    rtCode = connect (sockfd, addr, addrlen);
  } while (rtCode < 0 && errno == EINTR);
  canConnect = (0 == rtCode);
  do {
    rtCode = close (sockfd);
  } while (rtCode < 0 && errno == EINTR);
  return canConnect;
}

- (bool) _checkIPv4 {
  struct sockaddr_in sin_addr = {
    .sin_len = sizeof(struct sockaddr_in),
    .sin_family = AF_INET,
    .sin_port = htons(0xFFFF),
    .sin_addr.s_addr = htonl(0x08080808L)
  };
  return [self _canConnectWithPF:PF_INET addr:(struct sockaddr *)&sin_addr addrlen:sizeof (struct sockaddr_in)];
}

- (bool) _checkIPv6 {
  struct sockaddr_in6 sin6_addr = {
    .sin6_len = sizeof(struct sockaddr_in6),
    .sin6_family = AF_INET6,
    .sin6_port = htons(0xFFFF),
    .sin6_addr.s6_addr = {
      0x20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  };
  return [self _canConnectWithPF:PF_INET6 addr:(struct sockaddr *)&sin6_addr addrlen:sizeof (struct sockaddr_in6)];
}

- (NEIPStack) checkIPStack {
  NEIPStack is = NEIS_Unkown;
  if ([self _checkIPv4]) is |= NEIS_IPv4;
  if ([self _checkIPv6]) is |= NEIS_IPv6;
  return is;
}
@end
