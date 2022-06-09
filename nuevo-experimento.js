const fs = require('fs');

const original = process.argv.slice(2).join('');

const prefix = original.match(/^([A-Z]+)\d+T$/)[1];
const numberStr = original.match(/^[A-Z]+(\d+)T$/)[1];
const number = parseInt(numberStr, 10);
const suffix = 'T';

const newNumber = `${number + 1}`.padStart(4, '0');

const newName = [prefix, newNumber, suffix].join('');

console.log({
  original,
  prefix,
  numberStr,
  number,
  suffix,
  newNumber,
  newName,
});

if (process.cwd() !== '/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo') {
  console.log('Check current working dir matches project root.');
  process.exit(1);
}

fs.mkdirSync(`./exp/${newName}`);
fs.copyFileSync(`./exp/${original}/${original}.yml`, `./exp/${newName}/${newName}.yml`);
