import { createRequire } from 'node:module';
import { readFileSync, writeFileSync } from 'node:fs';
const require = createRequire(import.meta.url);
const React = require('react');
const svgpath = require('svgpath');
const {renderToStaticMarkup} = require('react-dom/server');
const upstreamIcons = require('@fluentui/react-icons');
const names = {
 check:'Checkmark24Regular', close:'Dismiss24Regular', plus:'Add24Regular', minus:'Subtract24Regular',
 down:'ChevronDown24Regular', left:'ChevronLeft24Regular', right:'ChevronRight24Regular', search:'Search24Regular',
 info:'Info24Regular', warning:'Warning24Regular', error:'ErrorCircle24Regular', success:'CheckmarkCircle24Regular',
 user:'Person24Regular', inbox:'MailInbox24Regular', sun:'WeatherSunny24Regular', moon:'WeatherMoon24Regular',
 settings:'Settings24Regular', arrowRight:'ArrowRight24Regular', copy:'Copy24Regular', code:'Code24Regular',
 grid:'Apps24Regular', experiment:'Beaker24Regular', loading:'ArrowSync24Regular', more:'MoreHorizontal24Regular', heart:'Heart24Regular', star:'Star24Regular',
};
const icons=Object.fromEntries(Object.entries(names).map(([name,upstream])=>{
 if(!upstreamIcons[upstream])throw new Error(`Missing official icon ${upstream}`);
 const svg=renderToStaticMarkup(React.createElement(upstreamIcons[upstream]));
 const sourcePaths=[...svg.matchAll(/<path\b[^>]*\bd="([^"]+)"/g)].map(m=>m[1]);
 const viewBox=svg.match(/viewBox="([^"]+)"/)[1].split(' ').map(Number);
 if(!sourcePaths.length || /fill-rule="evenodd"/.test(svg))throw new Error(`Unsupported icon ${upstream}`);
 // Compact relative contours render differently in Compose on Android API 24.
 // Explicit absolute commands and cubic arcs preserve the same SVG geometry
 // on Android, Skia desktop/Wasm and Flutter's path_drawing parser.
 const paths=sourcePaths.map(path=>{
   const normalized=[];
   svgpath(path).unshort().unarc().abs().round(6).iterate(segment=>{
     normalized.push(segment.join(' '));
   });
   return normalized.join(' ');
 });
 return [name,{upstream,viewBox,sourcePaths,paths}];
}));
const version=require('@fluentui/react-icons/package.json').version;
const output=JSON.stringify({source:'@fluentui/react-icons',repository:'https://github.com/microsoft/fluentui-system-icons',version,license:'MIT',icons},null,2)+'\n';
const destination=new URL('../../tokens/icons.json',import.meta.url);
if(process.argv.includes('--check')){if(readFileSync(destination,'utf8')!==output)throw new Error('Icon snapshot differs from pinned upstream.');}
else writeFileSync(destination,output);
console.log(`Verified/exported ${Object.keys(icons).length} official Fluent system icons (${version}).`);
