
return{
  // Use var result = BarcodeReader.run(ImageData.data, width, height);
  init: Module.cwrap('get_result', 'string', ['array','number','number'])
};

})();
