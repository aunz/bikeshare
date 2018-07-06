// extract geo result from google api 

const { readFileSync, writeFile } = require('fs')
const locations = readFileSync('./data/stations.txt').toString().split('\n')

const geo = {}
require('./data/geo.json').forEach(el => {
  const id = el.id
  geo[id] = el.results[0].geometry.location
  // console.log(id)
})

const results = []
for (let i = -1; ++i < locations.length;) {
  const s = locations[i].trim() + ',' + geo[i].lat + ',' + geo[i].lng
  results.push(s)
}

writeFile('./tmp/stations-geo.csv', results.join('\n'), () => {})