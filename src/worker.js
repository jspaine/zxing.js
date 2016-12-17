import zxingModule from './zxing-module'

export default function worker(self) {
  var Module = zxingModule({
    onRuntimeInitialized: () => self.postMessage({type: 'load'})
  })

  self.onmessage = function(ev) {
    const {data} = ev
    switch (data.type) {
      case 'decode':
        const start = Date.now()
        // multi not working
        Module.decode(data.image, data.width, data.height,
                      data.tryHarder, false, data.hybrid)

        const time = Date.now() - start
        if (Module.decodeStatus() !== 0) {
          self.postMessage({
            type: 'error',
            error: Module.errorString(),
            code: Module.decodeStatus(),
            time
          })
        } else {
          let results = []
          for (let i = 0; i < Module.numResults(); i++) {
            const numPoints = Module.numResultPoints(i)
            const bytes = numPoints * 2 * Uint16Array.BYTES_PER_ELEMENT
            const ptr = Module._malloc(bytes)

            Module.resultPoints(i, ptr)
            let points = Array.from(new Uint16Array(
              Module.HEAPU8.buffer,
              ptr,
              bytes / Uint16Array.BYTES_PER_ELEMENT
            )).map((el, j, arr) =>
              (j % 2 === 0) ? {x: el, y: arr[j+1]} : null
            ).filter((el, j) => el)
            Module._free(ptr)

            results[i] = {
              code: Module.resultString(i),
              format: Module.resultFormat(i),
              points,
              time
            }
          }

          self.postMessage({
            type: 'success',
            results
          })
        }
        break
    }
  }
}
