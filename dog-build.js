import React from 'react';
import path from 'path';
import fs from 'fs';
import lunr from 'lunr';
import { renderToString } from 'react-dom/server';
import wrapInHtml from './src/html-wrap';

const config = require('./dog.config');


function parsePackageJSON(module, idx) {
	const filePath = module.path;
	const {name, keywords, description} = require(path.resolve(filePath, 'package.json'));
	return {name, keywords, description: description.split(' '), id: idx, type: module.type}
}

const idx = lunr(function () {
    this.field('name', { boost: 10 });
    this.field('keywords', {boost: 8});
    this.field('description', {boost: 6});
})

const docs = config.map(parsePackageJSON);
const docsMap = docs.map((doc) => ({ [doc.id]: doc }))
					.reduce((res, obj) => Object.assign(res, obj), {})

docs.forEach((doc) => idx.add(doc));

fs.writeFile('./out/index.json', JSON.stringify(idx), function (err) {
    if (err) throw err
    console.log('>>> index done')
});

fs.writeFile('./out/docs-map.json', JSON.stringify(docsMap), function (err) {
    if (err) throw err
    console.log('>>> docs map done')
});

const resultHtml = wrapInHtml({ title: "test" })

fs.writeFile('./out/index.html', resultHtml, function (err) {
	if (err) throw err
    console.log('>>> index.html created');
})



