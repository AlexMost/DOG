import React from 'react';
import path from 'path';
import fs from 'fs';
import lunr from 'lunr';
import { renderToString } from 'react-dom/server';
import wrapInHtml from './src/html-wrap';
import { markdown } from 'markdown';
import mkdirp from 'mkdirp';
import documentation from 'documentation';

const config = require('./dog.config');


function parsePackageJSON(module, idx) {
	const filePath = module.path;
	const {name, keywords, description} = require(path.resolve(filePath, 'package.json'));
	return {name, keywords, description: description.split(' '), id: idx + module.type, type: module.type}
}

// npm
function parseREADME(module) {
	const mdContent = fs.readFileSync(path.resolve(module.path, 'README.md'), {encoding: 'utf-8'});
	const htmlContent = markdown.toHTML(mdContent);
	const dir = `./out/components/${path.basename(module.path)}`;
	mkdirp.sync(dir);
	fs.writeFile(`${dir}/README.md.html`, htmlContent, (err) => {
		if (err) throw err;
		console.log(`>>> ${module.name}/README.md.html done`);
	});
}

const idx = lunr(function () {
    this.field('name', { boost: 10 });
    this.field('keywords', {boost: 8});
    this.field('description', {boost: 6});
})

const docs = config.filter(({type}) => type === 'npm').map(parsePackageJSON);
config.forEach(parseREADME);

// --- lib type
let libdocs = [];
function parseLib(module, id) {
	const metaList = documentation.buildSync([module.files[0]]);
	const doc = {name: path.basename(module.path),
			keywords: [path.basename(module.path)], description: [], id: id + path.basename(module.path), type: module.type }
	console.log(doc)
	idx.add(doc);
	libdocs.push(doc);
	metaList.forEach((meta, idx2) => {
		const name = meta.name;
		const description = meta.description.children[0].children[0].value;
		const doc = {name, keywords: [], description: description.split(' '), 
			id: id + module.type + idx2, type: module.type, component: path.basename(module.path)}
		idx.add(doc);
		libdocs.push(doc)
	});
}

config.filter(({type}) => type === 'lib').forEach(parseLib)

const docIdsMap = docs.concat(libdocs).map((doc) => ({ [doc.id]: doc }));
const docNamesMap = docs.concat(libdocs).map((doc) => ({ [doc.name]: doc }));
const docsMap = docIdsMap.concat(docNamesMap)
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
