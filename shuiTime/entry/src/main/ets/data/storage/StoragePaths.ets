import { DATA_ROOT_DIR, ITEM_STORE_FILE_NAME, MEDIA_ROOT_DIR, TEMP_ROOT_DIR } from '../../common/constants/AppConstants';
export class StoragePaths {
  private readonly filesDir: string

  constructor(filesDir: string) {
    this.filesDir = filesDir;
  }

  get appRootDir(): string {
    return `${this.filesDir}/shuiTime`;
  }

  get dataRootDir(): string {
    return `${this.filesDir}/${DATA_ROOT_DIR}`;
  }

  get mediaRootDir(): string {
    return `${this.filesDir}/${MEDIA_ROOT_DIR}`;
  }

  get imageRootDir(): string {
    return `${this.mediaRootDir}/images`;
  }

  get videoRootDir(): string {
    return `${this.mediaRootDir}/videos`;
  }

  get tempRootDir(): string {
    return `${this.filesDir}/${TEMP_ROOT_DIR}`;
  }

  get itemStorePath(): string {
    return `${this.dataRootDir}/${ITEM_STORE_FILE_NAME}`;
  }
}
