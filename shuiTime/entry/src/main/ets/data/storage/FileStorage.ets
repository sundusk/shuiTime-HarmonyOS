import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';

export class FileStorage {
  ensureDir(path: string): void {
    const normalized = path.replace(/\/+$/g, '');
    if (normalized.length === 0) {
      return;
    }

    const parts = normalized.split('/').filter((segment: string) => segment.length > 0);
    let current = normalized.startsWith('/') ? '/' : '';
    parts.forEach((segment: string) => {
      current = current === '/' ? `${current}${segment}` : `${current}/${segment}`;
      if (!fs.accessSync(current)) {
        fs.mkdirSync(current);
      }
    });
  }
  writeText(path: string, content: string): void {
    this.ensureDir(path.substring(0, path.lastIndexOf('/')));
    if (fs.accessSync(path)) {
      fs.unlinkSync(path);
    }
    const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    try {
      const encoder = new util.TextEncoder();
      fs.writeSync(file.fd, encoder.encodeInto(content));
    } finally {
      fs.closeSync(file);
    }
  }
  readText(path: string): string {
    if (!fs.accessSync(path)) {
      return '';
    }

    const file = fs.openSync(path, fs.OpenMode.READ_WRITE);
    try {
      const stat = fs.statSync(path);
      if (stat.size <= 0) {
        return '';
      }

      const buffer = new ArrayBuffer(stat.size);
      const options: ReadOptions = {
        offset: 0,
        length: stat.size
      };
      const readLength = fs.readSync(file.fd, buffer, options);
      const decoder = new util.TextDecoder();
      return decoder.decode(new Uint8Array(buffer, 0, readLength));
    } finally {
      fs.closeSync(file);
    }
  }
  writeBytes(path: string, content: Uint8Array): void {
    this.ensureDir(path.substring(0, path.lastIndexOf('/')));
    if (fs.accessSync(path)) {
      fs.unlinkSync(path);
    }
    const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    try {
      fs.writeSync(file.fd, content);
    } finally {
      fs.closeSync(file);
    }
  }
  readBytes(path: string): Uint8Array {
    if (!fs.accessSync(path)) {
      return new Uint8Array(0);
    }

    const file = fs.openSync(path, fs.OpenMode.READ_WRITE);
    try {
      const stat = fs.statSync(path);
      if (stat.size <= 0) {
        return new Uint8Array(0);
      }
      const buffer = new ArrayBuffer(stat.size);
      const options: ReadOptions = {
        offset: 0,
        length: stat.size
      };
      const readLength = fs.readSync(file.fd, buffer, options);
      return new Uint8Array(buffer.slice(0, readLength));
    } finally {
      fs.closeSync(file);
    }
  }
  list(path: string): string[] {
    if (!fs.accessSync(path)) {
      return [];
    }
    return fs.listFileSync(path);
  }
  exists(path: string): boolean {
    return fs.accessSync(path);
  }
}
