/*
 *  Copyright (c) 2014 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "webrtc/modules/audio_coding/codecs/g729/interface/audio_encoder_g729.h"

#include <limits>
#include "webrtc/base/checks.h"
#include "webrtc/modules/audio_coding/codecs/g729/interface/g729_interface.h"

namespace webrtc {

namespace {

const int kSampleRateHz = 8000;

}  // namespace

AudioEncoderG729::AudioEncoderG729(const Config& config)
    : payload_type_(config.payload_type),
      num_10ms_frames_per_packet_(config.frame_size_ms / 10),
      num_10ms_frames_buffered_(0) {
  CHECK(config.frame_size_ms == 20 || config.frame_size_ms == 30 ||
        config.frame_size_ms == 40 || config.frame_size_ms == 60)
      << "Frame size must be 20, 30, 40, or 60 ms.";
  DCHECK_LE(kSampleRateHz / 100 * num_10ms_frames_per_packet_,
            kMaxSamplesPerPacket);
  CHECK_EQ(0, WebRtcG729_CreateEnc(&encoder_));
  /*
  const int encoder_frame_size_ms = config.frame_size_ms > 30
                                        ? config.frame_size_ms / 2
                                        : config.frame_size_ms; */
  CHECK_EQ(0, WebRtcG729_EncoderInit(encoder_, 0));
}

AudioEncoderG729::~AudioEncoderG729() {
  CHECK_EQ(0, WebRtcG729_FreeEnc(encoder_));
}

int AudioEncoderG729::SampleRateHz() const {
  return kSampleRateHz;
}
int AudioEncoderG729::NumChannels() const {
  return 1;
}
int AudioEncoderG729::Num10MsFramesInNextPacket() const {
  return num_10ms_frames_per_packet_;
}
int AudioEncoderG729::Max10MsFramesInAPacket() const {
  return num_10ms_frames_per_packet_;
}

void AudioEncoderG729::EncodeInternal(uint32_t rtp_timestamp,
                                      const int16_t* audio,
                                      size_t max_encoded_bytes,
                                      uint8_t* encoded,
                                      EncodedInfo* info) {
  size_t expected_output_len;
  switch (num_10ms_frames_per_packet_) {
    case 1:
      expected_output_len = 10;
      break;
    case 2:
      expected_output_len = 20;
      break;
    case 3:
      expected_output_len = 30;
      break;
    case 4:
      expected_output_len = 40;
      break;
    case 6:
      expected_output_len = 60;
      break;
    default:
      FATAL();
  }
  DCHECK_GE(max_encoded_bytes, expected_output_len);

  // Save timestamp if starting a new packet.
  if (num_10ms_frames_buffered_ == 0)
    first_timestamp_in_buffer_ = rtp_timestamp;

  // Buffer input.
  std::memcpy(input_buffer_ + kSampleRateHz / 100 * num_10ms_frames_buffered_,
              audio,
              kSampleRateHz / 100 * sizeof(audio[0]));

  // If we don't yet have enough buffered input for a whole packet, we're done
  // for now.
  if (++num_10ms_frames_buffered_ < num_10ms_frames_per_packet_) {
    info->encoded_bytes = 0;
    return;
  }

  // Encode buffered input.
  DCHECK_EQ(num_10ms_frames_buffered_, num_10ms_frames_per_packet_);
  num_10ms_frames_buffered_ = 0;
  const int output_len = WebRtcG729_Encode(
      encoder_,
      input_buffer_,
      kSampleRateHz / 100 * num_10ms_frames_per_packet_,
      encoded);
  CHECK_GE(output_len, 0);
  DCHECK_EQ(output_len, static_cast<int>(expected_output_len));
  info->encoded_bytes = output_len;
  info->encoded_timestamp = first_timestamp_in_buffer_;
  info->payload_type = payload_type_;
}

}  // namespace webrtc
