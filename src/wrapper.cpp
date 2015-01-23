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

using namespace std;
using namespace zxing;

namespace {

bool more = false;
bool test_mode = false;
bool try_harder = false;
bool search_multi = false;
bool use_hybrid = false;
bool use_global = false;
bool verbose = false;

}

vector<Ref<Result> > decode(Ref<BinaryBitmap> image, DecodeHints hints) {
  Ref<Reader> reader(new MultiFormatReader);
  return vector<Ref<Result> >(1, reader->decode(image, hints));
}

const char *read_image(Ref<LuminanceSource> source, bool hybrid, string expected) {
  vector<Ref<Result> > results;
  string cell_result;
  string result = string();
  int res = -1;

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
    results = decode(binary, hints);
  }
  catch (int e) {
    return string('error %i', e).c_str(); 
  }
  
  if (results.size() == 1) {
    result = results[0]->getText()->getText();
  }
  
  return result.c_str();
}

extern "C" const char *get_result(char *data, int width, int height) {
  Ref<LuminanceSource> source;
  
  source = ImageDataSource::create(data, width, height);
  
  string expected = string();
  
  return read_image(source, true, expected);
}
