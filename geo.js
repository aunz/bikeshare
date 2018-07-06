// find lon and lat from google API

const qs = require('querystring')
const { promisify } = require('util')

const { readFileSync } = require('fs')
const appendFile = promisify(require('fs').appendFile)

const fetch = require('node-fetch')

require('dotenv').config()

const URL = 'https://maps.googleapis.com/maps/api/geocode/json?key=' + process.env.GG_KEY + '&address='
const baseAddress = ',toronto,canada'

const locations = readFileSync('./tmp/stations.txt').toString().split('\n')


;(async function () {

  const tasks = {}
  const l = locations.length - 1
  // const l = 30
  

  for (let i = -1; i++ < l;) {
    const url = URL + qs.escape(locations[i] + baseAddress)
    console.log(i, locations[i])

    const task = fetch(url)
      .then(r => r.json())
      .then(r => {
        if (!r.results.length) console.log('No result for', i, locations[i])
        r.id = i
        return appendFile('./tmp/geo.json', JSON.stringify(r))
      })
      .finally(() => {
        delete tasks[i]
      })

    tasks[i] = task

    if (Object.keys(tasks).length === 10 || i === l) {
      await Promise.race(Object.values(tasks))
    }

  }
 
}())

// fetch(URL + qs.escape(locations[0] + baseAddress))
//   .then(r => r.json())
//   .then(r => {
//     r.id = 0
//     appendFile('./tmp/geo.json', JSON.stringify(r), () => {})
//   })



