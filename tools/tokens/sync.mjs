// Microsoft Fluent 2 theme exports are the source of truth. React is build-time only.
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync } from 'node:fs';
const require = createRequire(import.meta.url);
const theme = require('@fluentui/react-theme');
const { version } = require('@fluentui/react-theme/package.json');
const root = new URL('../../', import.meta.url);
const colorKeys = [...new Set([
  ...['1', '2', '3'].flatMap(n => ['', 'Hover', 'Pressed', 'Selected'].map(s => `colorNeutralForeground${n}${s}`)),
  'colorNeutralForeground4', 'colorNeutralForegroundDisabled', 'colorNeutralForegroundOnBrand', 'colorNeutralForegroundInverted',
  'colorNeutralForeground2BrandHover', 'colorNeutralForeground2BrandPressed',
  ...['1', '2', '3'].flatMap(n => ['', 'Hover', 'Pressed', 'Selected'].map(s => `colorNeutralBackground${n}${s}`)),
  'colorNeutralBackground4', 'colorNeutralBackground5', 'colorNeutralBackground6', 'colorNeutralBackgroundInverted', 'colorNeutralBackgroundDisabled',
  ...['1', '2', 'Accessible'].flatMap(n => ['', 'Hover', 'Pressed'].map(s => `colorNeutralStroke${n}${s}`)),
  'colorNeutralStrokeDisabled', 'colorNeutralStrokeAlpha', 'colorNeutralStencil1', 'colorNeutralStencil2',
  ...['', 'Hover', 'Pressed', 'Selected'].flatMap(s => [`colorBrandBackground${s}`, `colorSubtleBackground${s}`, `colorTransparentBackground${s}`]),
  ...['', 'Hover', 'Pressed'].flatMap(s => [`colorCompoundBrandBackground${s}`, `colorCompoundBrandForeground1${s}`, `colorCompoundBrandStroke${s}`, `colorBrandForegroundLink${s}`]),
  'colorBrandBackground2', 'colorBrandBackground2Hover', 'colorBrandBackground2Pressed', 'colorBrandForeground1', 'colorBrandForeground2', 'colorBrandForeground2Hover', 'colorBrandForeground2Pressed',
  'colorBrandStroke1', 'colorBrandStroke2', 'colorBrandStroke2Hover', 'colorBrandStroke2Pressed',
  'colorNeutralCardBackground', 'colorNeutralCardBackgroundHover',
  'colorStrokeFocus1', 'colorStrokeFocus2', 'colorBackgroundOverlay',
  'colorNeutralShadowAmbient', 'colorNeutralShadowKey',
  ...['Success', 'Warning', 'Danger'].flatMap(n => ['Background1','Background2','Background3','Foreground1','Foreground2','Foreground3','Border1','Border2','BorderActive'].map(s=>`colorStatus${n}${s}`)),
  'colorPaletteRedBackground3', 'colorPaletteDarkOrangeBackground3', 'colorPaletteGreenBackground3',
  'colorStatusDangerBackground3Hover', 'colorStatusDangerBackground3Pressed',
])].filter(k => k in theme.webLightTheme);
const numberKeys = Object.keys(theme.webLightTheme).filter(k => /^(borderRadius|fontSize|lineHeight|fontWeight|strokeWidth|spacingHorizontal|spacingVertical|duration)/.test(k));
function argb(value) {
  if (value === 'transparent') return '#00000000';
  if (value.startsWith('#')) {
    let hex = value.slice(1);
    if (hex.length === 3 || hex.length === 4) hex = [...hex].map(c => c + c).join('');
    if (hex.length === 6) hex = 'ff' + hex;
    else if (hex.length === 8) hex = hex.slice(6) + hex.slice(0,6);
    else throw new Error(`Unexpected upstream hex: ${value}`);
    return `#${hex}`.toUpperCase();
  }
  const parts = value.match(/^rgba?\(\s*(\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\s*\)$/);
  if (!parts) throw new Error(`Unexpected upstream color: ${value}`);
  return '#' + [Math.round(Number(parts[4] ?? 1) * 255), ...parts.slice(1,4).map(Number)].map(n=>n.toString(16).padStart(2,'0')).join('').toUpperCase();
}
const themes = {light:theme.webLightTheme, dark:theme.webDarkTheme, teamsLight:theme.teamsLightTheme, teamsDark:theme.teamsDarkTheme};
const modes = Object.fromEntries(Object.entries(themes).map(([name,t])=>[name,{
  isDark:name.toLowerCase().includes('dark'),
  colors:Object.fromEntries(colorKeys.map(k=>[k,argb(t[k])])),
  dimensions:Object.fromEntries(numberKeys.map(k=>{const n=parseFloat(t[k]);if(!Number.isFinite(n))throw new Error(`Invalid token ${k}`);return [k,n];})),
  typography:Object.fromEntries(Object.entries(t).filter(([k])=>k.startsWith('fontFamily'))),
  curves:Object.fromEntries(Object.entries(t).filter(([k])=>k.startsWith('curve'))),
  shadows:Object.fromEntries(Object.entries(t).filter(([k])=>k.startsWith('shadow'))),
}]));
const output = JSON.stringify({source:'https://github.com/microsoft/fluentui', package:'@fluentui/react-theme',version,reactComponentsVersion:require('@fluentui/react-components/package.json').version,license:'MIT; see THIRD_PARTY_NOTICES.md',colorFormat:'#AARRGGBB',dimensionUnit:'Logical pixels; Compose fonts use sp. Weights are unitless; duration tokens are milliseconds.',modes},null,2)+'\n';
const destination=new URL('tokens/fluent2.json',root);
if(process.argv.includes('--check')) {if(readFileSync(destination,'utf8')!==output)throw new Error('Theme snapshot differs from pinned upstream. Run npm run sync.');}
else writeFileSync(destination,output);
console.log(`${process.argv.includes('--check')?'Verified':'Exported'} ${colorKeys.length} colors and ${numberKeys.length} numeric tokens in four official Fluent themes (${version}).`);
