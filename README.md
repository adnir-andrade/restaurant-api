![CI](https://github.com/adnir-andrade/restaurant-api/actions/workflows/ci.yml/badge.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.4.2-red)
![Rails](https://img.shields.io/badge/Rails-8.0.2-red)

# Restaurant API

A Rails API for managing restaurant menus and menu items, as part of a coding challenge.
___

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup Instructions](#getting-started)
- [Commands](#commands)
- [Endpoints](#endpoints)
    - [Import](#import)
    - [Restaurants](#restaurants)
    - [Menus](#menus)
    - [MenuItems](#menuitems)
- [JSON Format to Import Files](#json-format-to-import-files)
    - [Example JSON Structure](#example-json-structure)
    - [Required Fields](#required-fields)
    - [Limitations](#limitations)
- [Decision Log (Notion)](#decision-making-log-notion)

___

## Features

- [x] Level 1
    - Manage restaurant menus and their items
    - CRUD endpoints for `Menu` and `MenuItem`
    - Assign a menu item to a specific menu
    - Validations for required attributes
    - Structured JSON responses using serializers
    - Comprehensive test coverage with RSpec


- [x] Level 2
    - Register restaurants and assign multiple menus to each restaurant
    - Create `MenuItems` and associate them with multiple menus as needed
    - CRUD endpoints for `Restaurant`, `Menu` and `MenuItems`
    - List all `Restaurants`, `Menus`, and `MenuItems`
    - List all menus of a specific `Restaurant`
    - List all menu items of a specific `Menu`
    - List all menus a specific `MenuItem` belongs to
    - Validations for unique `MenuItem` names and `Menu` names within a given `Restaurant`
    - Even more tests to verify functionalities

- [x] Level 3
    - Import restaurants, menus, and menu items automatically using a JSON file.
        - This can be achieved through a POST request
        - Or by using the command-line.
    - In cases where there are duplicate items within menus during import, the system will automatically rename and
      duplicate these items, allowing the user to handle them later. This ensures no data loss while maintaining
      flexibility for future actions.
    - Import logs are generated with tags for easier assessment.
    - Logs generated through command-line are color-coded.
    - Command-line script offers options for silent mode (which suppresses logs) and logs-only mode (which only prints
      the logs).
    - More and more tests!

___

## Requirements

To run this project, you need the following tools installed:

- [Ruby 3.2.4](https://www.ruby-lang.org/en/documentation/installation/)
- [Rails 8.0.2](https://guides.rubyonrails.org/getting_started.html)
- [Docker with Compose](https://docs.docker.com/compose/install/)

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

## Import JSON Data

To import restaurant, menu, and menu item data from a JSON file, use the following command:

```bash

bin/import_json path/to/file.json [options]

```

### Options:

- `-h` or `--help`: Show help information about the command.
- `--silent`: Run in silent mode (no logs, only basic output).
- `--logs-only`: Print only the logs, ignoring other details like created records and errors.

### Examples:

```bash
bin/import_json spec/fixtures/files/sample.json
bin/import_json spec/fixtures/files/sample.json --silent
bin/import_json spec/fixtures/files/sample.json --logs-only
```

## Lint

To run the linter, simply use:

   ```bash
   bundle exec rubocop
   ```

## Tests

To run the test suite, use:

   ```bash
   bundle exec rspec
   ```

___

## Endpoints

### Import

| Method | Path    | Description                                                   |
|--------|---------|---------------------------------------------------------------|
| POST   | /import | Import restaurant, menu, and menu item data from a JSON file. |

### Restaurants

| Method | Path             | Description                                 |
|--------|------------------|---------------------------------------------|
| GET    | /restaurants     | List all restaurants and the menus they own |
| GET    | /restaurants/:id | Show a single restaurant and its menus      |
| POST   | /restaurants     | Create a new restaurant                     |
| PATCH  | /restaurants/:id | Update a restaurant                         |
| DELETE | /restaurants/:id | Delete a restaurant                         |

### Menus

| Method | Path             | Description              |
|--------|------------------|--------------------------|
| GET    | /menus           | List all menus           |
| GET    | /menus/:id       | Show a single menu       |
| GET    | /menus/:id/items | List all items in a menu |
| POST   | /menus           | Create a new menu        |
| PATCH  | /menus/:id       | Update a menu            |
| DELETE | /menus/:id       | Delete a menu            |

### MenuItems

| Method | Path                                    | Description                                         |
|--------|-----------------------------------------|-----------------------------------------------------|
| GET    | /menu_items                             | List all menu items and the menus they belong to    |
| GET    | /menu_items/:id                         | Show a single menu item and the menus it belongs to |
| POST   | /menu_items                             | Create a new menu item                              |
| POST   | /menu_items/:id/assign_to_menu/:menu_id | Assign a menu item to a specific menu               |
| PATCH  | /menu_items/:id                         | Update a menu item                                  |
| DELETE | /menu_items/:id                         | Delete a menu item                                  |

___

## JSON Format to import files

To successfully import restaurants, menus, and menu items, your JSON file must follow a specific structure. The file
should contain a list of restaurants, each with its menus and menu items. Below is the structure and the required fields
for each level:

### Example JSON Structure:

```json
{
  "restaurants": [
    {
      "name": "Restaurant Name",
      "description": "Description of the restaurant",
      "menus": [
        {
          "name": "Menu Name",
          "description": "Description of the menu",
          "menu_items": [
            {
              "name": "Menu Item Name",
              "price": 10.99,
              "description": "Description of the menu item"
            },
            {
              "name": "Another Menu Item",
              "price": 15.99,
              "description": "Description of another menu item"
            }
          ]
        }
      ]
    }
  ]
}
```

### Required Fields:

- `restaurants`: An array of restaurant objects.
    - `name`: The name of the restaurant (required).
    - `description`: A description of the restaurant (optional, but recommended).
- `menus`: Each restaurant can have multiple menus.
    - `name`: The name of the menu (required).
    - `description`: A description of the menu (optional, but recommended).
- `menu_items`: Each menu can have multiple menu items.
    - `name`: The name of the menu item (required).
    - `price`: The price of the menu item (required, must be a number).
    - `description`: A description of the menu item (optional, but recommended).

### Limitations:

- **Duplicate Items:** If there are duplicate menu items (i.e., menu items with the same name across menus), the system
  will automatically rename them by appending a suffix (e.g., “Menu Item Name random-number”). The user will have to
  decide later whether to keep the duplicates or manually resolve them.
- **Missing Fields:** Any missing required fields (e.g., name or price for menu items) will result in a skipped record,
  and an error will be logged.
- **Price Formatting:** The price field must be a number (e.g., 10.99). Strings or invalid formats will result
  in a skipped record.
- **Nested Structures:** The JSON structure must adhere to the hierarchy of restaurants → menus → menu items. Each level
  must be nested correctly; otherwise, the import will fail.

___

## Decision Making Log (Notion)

Here is the link to a summary of the decision-making process during this challenge, documented in Notion.

Some of these thoughts are also written in the project's pull requests, which have not been deleted and can still be
read there.

[Decision Log on Notion](https://haotran.notion.site/Decision-Making-Restaurant-API-1ceef206b2be80ff8284fb21357f525a?pvs=4)