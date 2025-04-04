![CI](https://github.com/adnir-andrade/restaurant-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.4.2-red)
![Rails](https://img.shields.io/badge/Rails-8.0.2-red)

# Restaurant API

A Rails API for managing restaurant menus and menu items, as part of a coding challenge.

## Features

🚧 To be added in future iterations

___

## Getting Started

1. Clone the repo:
   ```bash
   git clone git@github.com:adnir-andrade/restaurant-api.git

2. Install dependencies:
   ```bash
   bundle install

3. Initiate container containing a postgres DB
   ```bash
   docker compose up -d
   ```

4. Setup the database
   ```bash
   rails db:create db:migrate
   ```

___

## Commands

### Lint

To run the linter, simply use:

   ```bash
   bundle exec rubocop
   ```

### Tests

To run the test suite, use:

   ```bash
   bundle exec rspec
   ```

