import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import { type TargetsType, TargetToNameMap } from './index';

// String-like keys will preserve insertion ordering. This is hacky but it looks nicer.
export const LanguageSelector = (props: Record<TargetsType, boolean | null>): JSX.Element => {
  if (Object.values(props).every((val) => (val == false))) {
    throw (new class extends Error {
      constructor() {
        super("LanguageSelector is used, but no language is supplied.");
        this.name = 'IllegalArgumentError';
      }
    }());
  }

  // Reorder languages in the c, cpp, py, rs, ts order.
  // https://stackoverflow.com/a/31102605
  const ordered = Object.keys(props).sort().reduce(
    (obj, key) => {
      obj[key] = props[key];
      return obj;
    },
    {}
  );

  return (
    <>
      <p>This article has examples in the following target languages:</p>
      <Tabs groupId="target-languages" 
      queryString 
      values={Object.entries(ordered).map(
          ([lang, exist]: [TargetsType, boolean], i) => (exist && {value: lang, label: TargetToNameMap.get(lang)})
        )} children={[]} />
    </>
  );
};