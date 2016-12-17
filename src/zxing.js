import work from 'webworkify-webpack'
// import ZxingWorker from 'worker-loader?inline!./worker.js'

class Zxing {
  constructor(opts) {
    this._worker = work(require.resolve('./worker.js'))
    this._worker.onmessage = this.handleWorkerMessage.bind(this)
    this._ready = false
    this._onSuccess = noop
    this._onError = noop
    this._onReady = noop
    this._options = {
      tryHarder: false,
      hybrid: true,
      ...opts
    }
  }

  onReady(fn) {
    if (typeof fn !== 'function') {
      this._onReady = noop
    } else {
      this._onReady = fn
    }
    if (this._ready) {
      fn()
    }
  }

  handleWorkerMessage(ev) {
    const {data} = ev
    switch (data.type) {
      case 'load':
        this._ready = true
        break
      case 'error':
        this._onError(data)
        this._ready = true
        break
      case 'success':
        this._onSuccess(data.results)
        this._ready = true
        break
    }
    if (this._ready) {
      this._onReady()
    }
  }

  isReady() { return this._ready }

  decode(image, width, height) {
    console.log('this._options', this._options)
    this._ready = false
    width = width || image.canvas.width
    height = height || image.canvas.height
    image = image.canvas ? image.getImageData(0, 0, width, height).data : image

    const result = new Promise((resolve, reject) => {
      this._onError = reject
      this._onSuccess = resolve
    })

    this._worker.postMessage({
      type: 'decode',
      image,
      width,
      height,
      tryHarder: this._options.tryHarder,
      multi: this._options.multi,
      hybrid: this._options.hybrid
    })

    return result
  }
}

module.exports = Zxing

function noop() {}
