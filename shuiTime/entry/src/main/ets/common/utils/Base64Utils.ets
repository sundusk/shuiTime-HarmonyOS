const BASE64_ALPHABET: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

export function encodeBase64(data: Uint8Array): string {
  let output = '';
  let index = 0;

  while (index < data.length) {
    const byte1 = data[index++];
    const byte2 = index < data.length ? data[index++] : -1;
    const byte3 = index < data.length ? data[index++] : -1;

    const enc1 = byte1 >> 2;
    const enc2 = ((byte1 & 0x03) << 4) | ((byte2 >= 0 ? byte2 : 0) >> 4);
    const enc3 = byte2 >= 0 ? (((byte2 & 0x0f) << 2) | ((byte3 >= 0 ? byte3 : 0) >> 6)) : 64;
    const enc4 = byte3 >= 0 ? (byte3 & 0x3f) : 64;

    output += BASE64_ALPHABET.charAt(enc1);
    output += BASE64_ALPHABET.charAt(enc2);
    output += enc3 === 64 ? '=' : BASE64_ALPHABET.charAt(enc3);
    output += enc4 === 64 ? '=' : BASE64_ALPHABET.charAt(enc4);
  }

  return output;
}

export function decodeBase64(base64: string): Uint8Array {
  const sanitized = base64.replace(/[^A-Za-z0-9+/=]/g, '');
  const bytes: number[] = [];
  let index = 0;

  while (index < sanitized.length) {
    const enc1 = BASE64_ALPHABET.indexOf(sanitized.charAt(index++));
    const enc2 = BASE64_ALPHABET.indexOf(sanitized.charAt(index++));
    const enc3Char = sanitized.charAt(index++);
    const enc4Char = sanitized.charAt(index++);
    const enc3 = enc3Char === '=' ? 64 : BASE64_ALPHABET.indexOf(enc3Char);
    const enc4 = enc4Char === '=' ? 64 : BASE64_ALPHABET.indexOf(enc4Char);

    const byte1 = (enc1 << 2) | (enc2 >> 4);
    bytes.push(byte1 & 0xff);

    if (enc3 !== 64) {
      const byte2 = ((enc2 & 0x0f) << 4) | (enc3 >> 2);
      bytes.push(byte2 & 0xff);
    }

    if (enc4 !== 64) {
      const byte3 = ((enc3 & 0x03) << 6) | enc4;
      bytes.push(byte3 & 0xff);
    }
  }

  return Uint8Array.from(bytes);
}
