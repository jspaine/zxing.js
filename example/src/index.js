var Zxing = require('../../dist/zxing')
var video = document.querySelector('#video')
var canvas = document.querySelector('#canvas')
var noSupp = document.querySelector('#not-supported')
var info = document.querySelector('#info')
var ctx = canvas.getContext('2d')

navigator.getUserMedia = navigator.getUserMedia ||
                          navigator.mozGetUserMedia ||
                          navigator.webkitGetUserMedia ||
                          navigator.msGetUserMedia

navigator.getUserMedia({
  video: true
}, function(stream) {
  video.src = window.URL.createObjectURL(stream)
}, function(err) {
  noSupp.innerHTML = 'getUserMedia not supported in this browser: ' + err
})

var zxing = new Zxing

zxing.onReady(function() {
  if (!video.videoWidth) return
  canvas.setAttribute('width', video.videoWidth)
  canvas.setAttribute('height', video.videoHeight)
  ctx.drawImage(video, 0, 0)
  zxing.decode(ctx)
    .then(function(result) {
      info.innerHTML = ''
      ctx.strokeStyle = '#39ff14'
      ctx.lineWidth = 4

      result.forEach(function(res) {
        info.innerHTML += res.code + ', Format: ' + res.format
        info.innerHTML += ', Time: ' + res.time + 'ms\n'
        drawPoints(ctx, res.points)
      })
    })
    .catch(function(error) {})
})

function drawPoints(ctx, points) {
  points.forEach(function(point, i) {
    if (i === 0) {
      ctx.beginPath()
      ctx.moveTo(point.x, point.y)
    } else {
      ctx.lineTo(point.x, point.y)
      ctx.stroke()
      ctx.beginPath()
      ctx.moveTo(point.x, point.y)
    }
  })
}
