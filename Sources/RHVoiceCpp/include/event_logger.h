//
//  event_logger.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 12/29/25.
//

#pragma once

#include "core/event_logger.hpp"
#include <memory>
#include <string>

extern "C" {

typedef void (*rh_log_cb)(void *ctx, const char *tag, int32_t level,
                          const char *message);

typedef void (*rh_destroy_cb)(void *ctx);
}

namespace RHVoiceCpp {

class event_logger : public RHVoice::event_logger {
public:
  event_logger(void *ctx, rh_log_cb log_cb, rh_destroy_cb destroy_cb)
      : ctx_(ctx), log_cb_(log_cb), destroy_cb_(destroy_cb) {}

  ~event_logger() override {
    if (destroy_cb_)
      destroy_cb_(ctx_);
  }

  void log(const std::string &tag, RHVoice_log_level level,
           const std::string &message) const override {
    if (!log_cb_)
      return;

    log_cb_(ctx_, tag.c_str(), static_cast<int32_t>(level), message.c_str());
  }

private:
  void *ctx_;
  rh_log_cb log_cb_;
  rh_destroy_cb destroy_cb_;
};

inline std::shared_ptr<RHVoice::event_logger> static make_event_logger(
    void *ctx, rh_log_cb log_cb, rh_destroy_cb destroy_cb) {
  return std::make_shared<RHVoiceCpp::event_logger>(ctx, log_cb, destroy_cb);
}

} // namespace RHVoiceCpp
