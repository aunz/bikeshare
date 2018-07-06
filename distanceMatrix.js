// find lon and lat from google API

const qs = require('querystring')
const { promisify } = require('util')

const { readFileSync } = require('fs')
const appendFile = promisify(require('fs').appendFile)

const fetch = require('node-fetch')

require('dotenv').config()

const URL = 'https://maps.googleapis.com/maps/api/distancematrix/json?key=' + process.env.GG_KEY + '&mode=bicycling&'
const baseAddress = ',toronto,canada'

const locations = readFileSync('./data/stations_from_to.csv').toString().split('\n')


;(async function () {

  const tasks = {}
  const l = locations.length - 1  

  for (let i = 22433; i++ < l;) {
    const location = locations[i].split(',').map(el => el.trim())
    const loc_from = 'origins=' + qs.escape(location[0] +  baseAddress)
    const loc_to = 'destinations=' + qs.escape(location[1] + baseAddress)

    const url = URL + loc_from + '&' + loc_to
    console.log(i, url)

    const task = fetch(url)
      .then(r => r.json())
      .then(r => {
        r = r.rows[0].elements[0]
        const s = location[0] + ',' + location[1] + ',' + r.distance.value + ',' + r.duration.value + '\n'
        return appendFile('./tmp/distancMatrix.csv', s)
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
