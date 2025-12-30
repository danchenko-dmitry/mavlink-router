/*
 * This file is part of the MAVLink Router project
 *
 * Copyright (C) 2017  Intel Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include "xtermios.h"

#include <string.h>
#include <termios.h>
#include <unistd.h>

int reset_uart(int fd)
{
    struct termios tc = {};
    /* See termios(3) */
    /* Workaround for GCC 15.2.0 bug: use memset + individual assignments to avoid .base64 assembler error */
    cc_t default_cc[32];
    memset(default_cc, 0, sizeof(default_cc));
    default_cc[0] = 3;    /* VINTR: Ctrl-C */
    default_cc[1] = 28;   /* VQUIT: Ctrl-\ */
    default_cc[2] = 127; /* VERASE: DEL */
    default_cc[3] = 21;   /* VKILL: Ctrl-U */
    default_cc[4] = 4;    /* VEOF: Ctrl-D */
    default_cc[8] = 17;  /* VSTART: Ctrl-Q */
    default_cc[9] = 19;  /* VSTOP: Ctrl-S */
    default_cc[10] = 26; /* VSUSP: Ctrl-Z */
    default_cc[11] = 18; /* VREPRINT: Ctrl-R */
    default_cc[12] = 15; /* VDISCARD: Ctrl-O */
    default_cc[13] = 23; /* VWERASE: Ctrl-W */
    default_cc[14] = 22; /* VLNEXT: Ctrl-V */
    
    if (sizeof(default_cc) != sizeof(tc.c_cc)) {
        return -1; /* Unknown termios struct with different size */
    }

    if (tcgetattr(fd, &tc) < 0) {
        return -1;
    }

    /* Put UART in known state: it's the equivalent of "sane" in stty */
    tc.c_cflag = CREAD;

    tc.c_iflag |= BRKINT | ICRNL | IMAXBEL;
    tc.c_iflag &= ~(INLCR | IGNCR | IUTF8 | IXOFF | IUCLC | IXANY);

    tc.c_oflag |= OPOST | ONLCR;
    tc.c_oflag &= ~(OLCUC | OCRNL | ONLRET | OFILL | OFDEL | NL0 | CR0 | TAB0 | BS0 | VT0 | FF0);

    tc.c_lflag |= ISIG | ICANON | IEXTEN | ECHO | ECHOE | ECHOK | ECHOCTL | ECHOKE;
    tc.c_lflag &= ~(ECHONL | NOFLSH | XCASE | TOSTOP | ECHOPRT);

    /* special characters to their default values */
    memcpy(tc.c_cc, default_cc, sizeof(default_cc));

    if (tcsetattr(fd, TCSANOW, &tc) < 0) {
        return -1;
    }

    cfsetspeed(&tc, B1200);

    if (tcsetattr(fd, TCSANOW, &tc) < 0) {
        return -1;
    }

    return 0;
}
