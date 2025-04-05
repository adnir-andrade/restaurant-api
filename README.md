![CI](https://github.com/adnir-andrade/restaurant-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.4.2-red)
![Rails](https://img.shields.io/badge/Rails-8.0.2-red)

# Restaurant API

A Rails API for managing restaurant menus and menu items, as part of a coding challenge.

## Features

- [x] Level 1
- Manage restaurant menus and their items
- CRUD endpoints for `Menu` and `MenuItem`
- Assign a menu item to a specific menu
- Validations for required attributes
- Structured JSON responses using serializers
- Comprehensive test coverage with RSpec

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

___

## Endpoints

### Menus

| Method | Path       | Description        |
|--------|------------|--------------------|
| GET    | /menus     | List all menus     |
| GET    | /menus/:id | Show a single menu |
| POST   | /menus     | Create a new menu  |
| PATCH  | /menus/:id | Update a menu      |
| DELETE | /menus/:id | Delete a menu      |

### MenuItems

| Method | Path                                    | Description                           |
|--------|-----------------------------------------|---------------------------------------|
| GET    | /menu_items                             | List all menu items                   |
| GET    | /menu_items/:id                         | Show a single menu item               |
| POST   | /menu_items                             | Create a new menu item                |
| PATCH  | /menu_items/:id                         | Update a menu item                    |
| DELETE | /menu_items/:id                         | Delete a menu item                    |
| POST   | /menu_items/:id/assign_to_menu/:menu_id | Assign a menu item to a specific menu |