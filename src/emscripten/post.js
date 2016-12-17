
  return {
    decode: Module.cwrap('decode', null, ['array', 'number', 'number', 'number', 'number', 'number']),
    decodeStatus: Module.cwrap('decode_status', 'number', []),
    errorString: Module.cwrap('error_string', 'string', []),
    numResults: Module.cwrap('num_results', 'number', []),
    resultString: Module.cwrap('result_string', 'string', ['number']),
    resultFormat: Module.cwrap('result_format', 'string', ['number']),
    numResultPoints: Module.cwrap('num_result_points', 'number', ['number']),
    resultPoints: Module.cwrap('result_points', null, ['number', 'number']),
    _malloc: Module._malloc,
    _free: Module._free,
    HEAPU8: Module.HEAPU8
  }
}
