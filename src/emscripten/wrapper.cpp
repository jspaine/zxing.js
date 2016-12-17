#include <string>
#include "ImageDataSource.h"
#include <zxing/common/Counted.h>
#include <zxing/Binarizer.h>
#include <zxing/MultiFormatReader.h>
#include <zxing/Result.h>
#include <zxing/ReaderException.h>
#include <zxing/common/GlobalHistogramBinarizer.h>
#include <zxing/common/HybridBinarizer.h>
#include <exception>
#include <zxing/Exception.h>
#include <zxing/common/IllegalArgumentException.h>
#include <zxing/BinaryBitmap.h>
#include <zxing/DecodeHints.h>
#include <zxing/multi/GenericMultipleBarcodeReader.h>

using namespace std;
using namespace zxing;
using namespace zxing::multi;

namespace {
  vector<Ref<Result> > results;
  int res;
  string error;
}

vector<Ref<Result> > decode_single(Ref<BinaryBitmap> image, DecodeHints hints) {
  Ref<Reader> reader(new MultiFormatReader);
  return vector<Ref<Result> >(1, reader->decode(image, hints));
}

vector<Ref<Result> > decode_multi(Ref<BinaryBitmap> image, DecodeHints hints) {
  MultiFormatReader delegate;
  GenericMultipleBarcodeReader reader(delegate);
  return reader.decodeMultiple(image, hints);
}

void read_image(Ref<LuminanceSource> source, bool try_harder,
                        bool multi, bool hybrid) {
  res = -1;
  error = string();
  results = vector<Ref<Result> >();
  try {
    Ref<Binarizer> binarizer;
    if (hybrid) {
      binarizer = new HybridBinarizer(source);
    } else {
      binarizer = new GlobalHistogramBinarizer(source);
    }
    DecodeHints hints(DecodeHints::DEFAULT_HINT);
    hints.setTryHarder(try_harder);
    Ref<BinaryBitmap> binary(new BinaryBitmap(binarizer));
    if (multi) {
      results = decode_multi(binary, hints);
    } else {
      results = decode_single(binary, hints);
    }
    res = 0;
  } catch (const ReaderException& e) {
    error.assign("zxing::ReaderException: " + string(e.what()));
    res = -2;
  } catch (const zxing::IllegalArgumentException& e) {
    error = "zxing::IllegalArgumentException: " + string(e.what());
    res = -3;
  } catch (const zxing::Exception& e) {
    error = "zxing::Exception: " + string(e.what());
    res = -4;
  } catch (const std::exception& e) {
    error = "std::exception: " + string(e.what());
    res = -5;
  }
}

extern "C" void decode(char *data, int width, int height,
                              int try_harder, int multi, int hybrid) {
  Ref<LuminanceSource> source = ImageDataSource::create(data, width, height);
  read_image(source, try_harder == 1, multi == 1, hybrid == 1);
}

extern "C" int decode_status() {
  return res;
}

extern "C" const char *error_string() {
  return error.c_str();
}

extern "C" int num_results() {
  return results.size();
}

extern "C" const char *result_string(int n) {
  return results[n]->getText()->getText().c_str();
}

extern "C" const char *result_format(int n) {
  return BarcodeFormat::barcodeFormatNames[results[n]->getBarcodeFormat()];
}

extern "C" int num_result_points(int n) {
  return results[n]->getResultPoints()->size();
}

extern "C" void result_points(int n, unsigned short *buffer) {
  ArrayRef<Ref<ResultPoint> > points = results[n]->getResultPoints();
  for (int i = 0; i < points->size(); i++) {
    buffer[i*2] = points[i]->getX();
    buffer[i*2+1] = points[i]->getY();
  }
}
