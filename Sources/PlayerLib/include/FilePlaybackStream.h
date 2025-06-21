/* Copyright (C) 2012, 2013, 2018  Olga Yakovleva <yakovleva.o.v@gmail.com> */

/* This program is free software: you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation, either version 2 of the License, or */
/* (at your option) any later version. */

/* This program is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/* GNU General Public License for more details. */

/* You should have received a copy of the GNU General Public License */
/* along with this program.  If not, see <https://www.gnu.org/licenses/>. */


#ifndef FilePlaybackStream_h
#define FilePlaybackStream_h

#include <memory>

#include "core/client.hpp"

namespace PlayerLib
{
    class FilePlaybackStream: public RHVoice::client
    {
    public:
        FilePlaybackStream(const char *path);
        bool play_speech(const short *samples, std::size_t count);
        void finish();
        bool set_sample_rate(int sample_rate);
        bool set_buffer_size(unsigned int buffer_size);

    private:
        class Impl;
        std::shared_ptr<Impl> pimpl;
    };
}
#endif /* FilePlaybackStream_h */
