#!/usr/bin/env node

/**
 * CFJJB Competition Calendar Scraper
 *
 * This script fetches the competition calendar from cfjjb.com
 * and generates an Elm data file with all French competitions.
 *
 * Usage: node scripts/scrape-cfjjb.js
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const CFJJB_URL = 'https://cfjjb.com/competitions/calendrier-competitions';
const OUTPUT_FILE = path.join(__dirname, '..', 'src', 'Data', 'CFJJBEvents.elm');

/**
 * Fetch HTML content from URL
 */
function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve(data);
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * Parse HTML to extract competition data
 * This is a basic parser - we'll use regex for simplicity
 */
function parseCompetitions(html) {
  const competitions = [];

  // Extract month sections
  const monthRegex = /<h3[^>]*>([^<]+)<\/h3>([\s\S]*?)(?=<h3|$)/g;
  let monthMatch;

  while ((monthMatch = monthRegex.exec(html)) !== null) {
    const monthName = monthMatch[1].trim();
    const monthContent = monthMatch[2];

    // Extract competition entries within this month
    // Looking for patterns like competition name, date, location
    const competitionRegex = /<div[^>]*class="[^"]*competition[^"]*"[^>]*>([\s\S]*?)<\/div>/g;
    let compMatch;

    while ((compMatch = competitionRegex.exec(monthContent)) !== null) {
      const compHTML = compMatch[1];

      // Extract details (this is simplified - adjust based on actual HTML structure)
      const nameMatch = compHTML.match(/<h4[^>]*>([^<]+)<\/h4>/);
      const dateMatch = compHTML.match(/(\d{1,2})\s+(\w+)\s+(\d{4})/);
      const locationMatch = compHTML.match(/<span[^>]*class="[^"]*location[^"]*"[^>]*>([^<]+)<\/span>/);
      const statusMatch = compHTML.match(/Validé|A confirmer/);

      if (nameMatch && dateMatch) {
        const comp = {
          name: nameMatch[1].trim(),
          date: parseDate(dateMatch[0]),
          location: locationMatch ? locationMatch[1].trim() : '',
          status: statusMatch ? statusMatch[0] : 'A confirmer',
          categories: extractCategories(nameMatch[1])
        };

        competitions.push(comp);
      }
    }
  }

  return competitions;
}

/**
 * Parse French date to YYYY-MM-DD format
 */
function parseDate(dateStr) {
  const months = {
    'janvier': '01', 'février': '02', 'mars': '03', 'avril': '04',
    'mai': '05', 'juin': '06', 'juillet': '07', 'août': '08',
    'septembre': '09', 'octobre': '10', 'novembre': '11', 'décembre': '12'
  };

  const match = dateStr.match(/(\d{1,2})\s+(\w+)\s+(\d{4})/);
  if (!match) return '';

  const day = match[1].padStart(2, '0');
  const month = months[match[2].toLowerCase()] || '01';
  const year = match[3];

  return `${year}-${month}-${day}`;
}

/**
 * Extract competition categories from name
 */
function extractCategories(name) {
  const categories = [];
  const nameLower = name.toLowerCase();

  if (nameLower.includes('no gi') || nameLower.includes('nogi')) {
    categories.push('NoGi');
  } else if (nameLower.includes('kids') || nameLower.includes('enfant')) {
    categories.push('Kids');
  } else {
    categories.push('Gi');
  }

  return categories;
}

/**
 * Extract location details
 */
function parseLocation(locationStr) {
  // Try to parse city, region format
  const parts = locationStr.split(',').map(s => s.trim());

  return {
    city: parts[0] || locationStr,
    region: parts[1] || '',
    country: 'France'
  };
}

/**
 * Generate Elm module with competition data
 */
function generateElmModule(competitions) {
  const header = `module Data.CFJJBEvents exposing (cfjjbEvents)

{-| French BJJ Competitions from CFJJB
Auto-generated from https://cfjjb.com/competitions/calendrier-competitions

Last updated: ${new Date().toISOString()}
-}

import Dict exposing (Dict)
import Types exposing (..)


cfjjbEvents : Dict String Event
cfjjbEvents =
    Dict.fromList
`;

  const events = competitions.map((comp, index) => {
    const id = `cfjjb-${index + 1}`;
    const location = parseLocation(comp.location);
    const eventType = comp.categories.includes('Kids') ? 'Camp' : 'Tournament';
    const status = comp.status === 'Validé' ? 'EventUpcoming' : 'EventUpcoming';

    return `        ( "${id}"
        , { id = "${id}"
          , name = "${comp.name.replace(/"/g, '\\"')}"
          , date = "${comp.date}"
          , location =
              { city = "${location.city.replace(/"/g, '\\"')}"
              , state = "${location.region.replace(/"/g, '\\"')}"
              , country = "${location.country}"
              , address = ""
              , coordinates = Nothing
              }
          , organization = "CFJJB"
          , type_ = ${eventType}
          , imageUrl = "/images/events/cfjjb-default.jpg"
          , description = "Compétition de Jiu-Jitsu Brésilien - ${comp.name.replace(/"/g, '\\"')}"
          , registrationUrl = Just "https://cfjjb.com/competitions/calendrier-competitions"
          , streamUrl = Nothing
          , results = Nothing
          , brackets = []
          , status = ${status}
          }
        )`;
  }).join('\n');

  const footer = `
`;

  return header + '        [' + events + '\n        ]\n' + footer;
}

/**
 * Main execution
 */
async function main() {
  try {
    console.log('🔍 Fetching CFJJB competition calendar...');
    const html = await fetchHTML(CFJJB_URL);

    console.log('📋 Parsing competitions...');
    const competitions = parseCompetitions(html);

    console.log(`✅ Found ${competitions.length} competitions`);

    console.log('📝 Generating Elm module...');
    const elmCode = generateElmModule(competitions);

    // Ensure directory exists
    const dir = path.dirname(OUTPUT_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(OUTPUT_FILE, elmCode, 'utf8');
    console.log(`✅ Generated: ${OUTPUT_FILE}`);

    // Also save raw JSON for debugging
    const jsonFile = path.join(__dirname, 'cfjjb-events.json');
    fs.writeFileSync(jsonFile, JSON.stringify(competitions, null, 2), 'utf8');
    console.log(`✅ Saved JSON: ${jsonFile}`);

    console.log('\n✨ Scraping complete!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
