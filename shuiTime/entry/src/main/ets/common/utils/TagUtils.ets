const TAG_PATTERN: RegExp = /#[A-Za-z0-9_\-\u4e00-\u9fa5]+/g;

export function extractTags(content: string): string[] {
  const matches = content.match(TAG_PATTERN);
  if (!matches || matches.length === 0) {
    return [];
  }

  const uniqueTags: string[] = [];
  matches.forEach((tag: string) => {
    if (!uniqueTags.includes(tag)) {
      uniqueTags.push(tag);
    }
  });
  return uniqueTags;
}
