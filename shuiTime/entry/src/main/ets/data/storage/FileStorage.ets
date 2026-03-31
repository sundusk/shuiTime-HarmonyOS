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
    console.log('FileStorage.writeText: 开始写入文件:', path);
    this.ensureDir(path.substring(0, path.lastIndexOf('/')));

    try {
      console.log('FileStorage.writeText: 打开目标文件并清空旧内容');
      const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.SYNC);

      try {
        console.log('FileStorage.writeText: 写入内容，长度:', content.length);
        const writeResult = fs.writeSync(file.fd, content);
        console.log('FileStorage.writeText: 写入成功，写入字节数:', writeResult);
        fs.fsyncSync(file.fd);
      } finally {
        fs.closeSync(file);
        console.log('FileStorage.writeText: 文件已关闭');
      }
      console.log('FileStorage.writeText: 写入完成');
    } catch (error) {
      console.error('FileStorage.writeText: 写入失败:', error);
      throw new Error('写入文件失败');
    }
  }
  readText(path: string): string {
    console.log('FileStorage.readText: 开始读取文件:', path);
    if (!fs.accessSync(path)) {
      console.log('FileStorage.readText: 文件不存在');
      return '';
    }

    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);

      try {
        const stat = fs.statSync(path);
        console.log('FileStorage.readText: 文件大小:', stat.size);

        if (stat.size <= 0) {
          throw new Error(`文件为空: ${path}`);
        }

        const buffer = new ArrayBuffer(stat.size);
        const options: ReadOptions = {
          offset: 0,
          length: stat.size
        };
        const readLength = fs.readSync(file.fd, buffer, options);
        console.log('FileStorage.readText: 读取字节数:', readLength);

        const decoder = new util.TextDecoder();
        const result = decoder.decode(new Uint8Array(buffer, 0, readLength));
        console.log('FileStorage.readText: 读取内容长度:', result.length);
        return result;
      } finally {
        fs.closeSync(file);
      }
    } catch (error) {
      console.error('FileStorage.readText: 读取失败:', error);
      throw new Error('读取文件失败');
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
