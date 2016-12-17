# zxing.js

Emscripten port of [zxing-cpp](https://github.com/glassechidna/zxing-cpp) for decoding barcodes in browser. A live demo can be seen [here](http://jspaine.github.io/zxing.js)

## Usage

```javascript
import Zxing from 'zxing'
const zxing = new Zxing

zxing.onReady = () => {
  zxing.decode(image, width, height)
    .then(results => console.log(results[0].code))
}
```

## API
**constructor(options)**

`options` is an object of:
property | default | description
--- | --- | ---
tryHarder | false | Spend more time to try to find a barcode; optimize for accuracy, not speed.
hybrid | true | See [docs](https://zxing.github.io/zxing/apidocs/com/google/zxing/common/HybridBinarizer.html)

**decode(ctx)**

Decode from a CanvasRenderingContext2D. Returns a promise that resolves to an array of results

**decode(image, width, height)**

Decode from an image as a 1D array

**onReady(fn)**

Add a callback function fn to be executed when the decode becomes ready

**isReady()**

Returns if the decoder is ready

## Building

To build the asm.js module, make sure emcc is on your path then

```
git submodule init
git submodule update
./build.sh
```



```
npm install
npm run build
```
