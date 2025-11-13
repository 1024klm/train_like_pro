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
const RAW_HTML_FILE = path.join(__dirname, 'cfjjb-raw.html');

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
  // Save raw HTML for debugging
  try { fs.writeFileSync(RAW_HTML_FILE, html, 'utf8'); } catch (_) {}

  // Structured parser based on observed markup: each event name is inside
  // <p id="compet_XXX">Name</p>, then a date "Le ..." or "Du ... au ...",
  // then a <p> with the city, and a status span containing "Validé"/"A confirmer".
  const competitions = [];
  const nameRegex = /<p[^>]*id="compet_\d+"[^>]*>\s*([\s\S]*?)<\/p>/gi;
  let match;
  while ((match = nameRegex.exec(html)) !== null) {
    const rawName = stripTags(match[1]).trim();
    if (!rawName) continue;

    const context = html.slice(match.index, match.index + 4000);
    const dateMatch = context.match(/Le\s+\d{1,2}\s+\w+\s+\d{4}|Du\s+\d{1,2}\s+\w+\s+au\s+\d{1,2}\s+\w+/i);
    const statusMatch = context.match(/Validé|A confirmer/i);

    // Find first <p> after the date, assume it's the city
    let city = '';
    if (dateMatch) {
      const afterDate = context.slice(context.indexOf(dateMatch[0]) + dateMatch[0].length);
      const cityTag = afterDate.match(/<p[^>]*>\s*([^<]+?)\s*<\/p>/i);
      if (cityTag) city = stripTags(cityTag[1]).trim();
    }

    if (dateMatch && city) {
      competitions.push({
        name: rawName,
        date: parseFlexibleDate(dateMatch[0]) || '',
        location: city,
        status: statusMatch ? statusMatch[0] : 'A confirmer',
        categories: extractCategories(rawName)
      });
    }
  }

  return dedupeCompetitions(competitions);
}

function parseFlexibleDate(raw) {
  // Handles "Le 4 octobre 2025" or "Du 29 novembre au 30 novembre"
  const single = raw.match(/\b(\d{1,2})\s+(\w+)\s+(\d{4})\b/i);
  if (single) return parseDate(single[0]);

  const range = raw.match(/Du\s+(\d{1,2})\s+(\w+)\s+au\s+(\d{1,2})\s+(\w+)/i);
  if (range) {
    const day = range[1];
    const month = range[2];
    const yearMatch = raw.match(/(\d{4})/);
    const year = yearMatch ? yearMatch[1] : new Date().getFullYear().toString();
    return parseDate(`${day} ${month} ${year}`);
  }
  return '';
}

function stripTags(s) {
  return s.replace(/<[^>]+>/g, '');
}

function slugify(str) {
  return str
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

function dedupeCompetitions(list) {
  const seen = new Set();
  return list.filter(c => {
    const key = `${c.name}|${c.date}|${c.location}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
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
    const id = `cfjjb-${slugify(comp.name)}-${comp.date || (index + 1)}`;
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
  }).join(',\n');

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
