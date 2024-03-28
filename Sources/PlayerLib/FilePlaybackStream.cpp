//
//  RHVoiceWrapper.cpp
//
//
//  Created by Ihor Shevchuk on 01.02.2023.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#include <stdio.h>

#include <string>
#include <stdexcept>
#include <iostream>
#include <fstream>
#include <iterator>
#include <algorithm>

#include "core/engine.hpp"
#include "core/document.hpp"
#include "core/client.hpp"
#include "audio.hpp"

#include "FilePlaybackStream.h"

namespace PlayerLib
{
    class FilePlaybackStream::Impl
    {
    public:
        Impl(const std::string &path)
        {
            if (!path.empty())
            {
                stream.set_backend(RHVoice::audio::backend_file);
                stream.set_device(path);
            }
        }

        ~Impl() = default;

        bool play_speech(const short *samples, std::size_t count)
        {
            try
            {
                if (!stream.is_open())
                {
                    stream.open();
                }
                stream.write(samples, count);
                return true;
            }
            catch (...)
            {
                stream.close();
                return false;
            }
        }

        void finish()
        {
            if (stream.is_open())
            {
                stream.drain();
            }
        }

        bool set_sample_rate(int sample_rate)
        {
            try
            {
                if (stream.is_open() && (stream.get_sample_rate() != sample_rate))
                {
                    stream.close();
                }
                stream.set_sample_rate(sample_rate);
                return true;
            }
            catch (...)
            {
                return false;
            }
        }
        bool set_buffer_size(unsigned int buffer_size)
        {
            try
            {
                if (stream.is_open() && (stream.get_buffer_size() != buffer_size))
                {
                    stream.close();
                }
                stream.set_buffer_size(buffer_size);
                return true;
            }
            catch (...)
            {
                return false;
            }
        }

    private:
        RHVoice::audio::playback_stream stream;
    };

    FilePlaybackStream::FilePlaybackStream(const char *path) : pimpl(new Impl(path))
    {
    }

    bool FilePlaybackStream::set_sample_rate(int sample_rate)
    {
        return pimpl->set_sample_rate(sample_rate);
    }

    bool FilePlaybackStream::set_buffer_size(unsigned int buffer_size)
    {
        return pimpl->set_buffer_size(buffer_size);
    }

    bool FilePlaybackStream::play_speech(const short *samples, std::size_t count)
    {
        return pimpl->play_speech(samples, count);
    }

    void FilePlaybackStream::finish()
    {
        pimpl->finish();
    }

}
