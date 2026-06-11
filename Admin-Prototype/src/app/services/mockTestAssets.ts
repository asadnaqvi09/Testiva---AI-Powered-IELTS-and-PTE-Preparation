import { uploadTestAsset } from './api';
import type { BuilderSection } from '../context/MocksContext';

function isHttpUrl(value: string | null | undefined): boolean {
  return !!value && /^https?:\/\//i.test(value);
}

/** Upload pending section files and return sections with Cloudinary URLs set. */
export async function uploadSectionAssets(sections: BuilderSection[]): Promise<BuilderSection[]> {
  const out: BuilderSection[] = [];

  for (const sec of sections) {
    let next = { ...sec };
    const module = sec.moduleType.toLowerCase();

    if (sec.audioFileData) {
      const res = await uploadTestAsset(sec.audioFileData);
      next = {
        ...next,
        audioFile: res.data.url,
        audioFileData: null,
      };
    } else if (module.includes('listening') && sec.audioFile && !isHttpUrl(sec.audioFile)) {
      throw new Error(
        `Listening section "${sec.moduleType}" needs an audio upload (not just a filename).`,
      );
    }

    if (sec.chartImageData) {
      const res = await uploadTestAsset(sec.chartImageData);
      next = {
        ...next,
        chartImage: res.data.url,
        chartImageData: null,
      };
    }

    out.push(next);
  }

  return out;
}

export function getSectionAudioUrl(sec: BuilderSection): string | null {
  if (isHttpUrl(sec.audioFile)) return sec.audioFile;
  return null;
}

export function getSectionImageUrl(sec: BuilderSection): string | null {
  if (isHttpUrl(sec.chartImage)) return sec.chartImage;
  return null;
}
