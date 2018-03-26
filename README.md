This project is bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

## About

This is the frontend for a simple meeting room availability checking app (dubbed "Hodor") written for Slalom's Hack the Office 2017 hackathon. This is the first time any of the contributers have made an Elm application, so it might be a little rough around the edges ;)

## Installing Elm packages

```sh
elm-app install <package-name>
```

Other `elm-package` commands are also [available.](#package)

## Installing JavaScript packages

To use JavaScript packages from npm, you'll need to add a `package.json`, install the dependencies, and you're ready to go.

```sh
npm init -y # Add package.json
npm install --save-dev pouchdb-browser # Install library from npm
```

```js
// Use in your JS code
import PouchDB from 'pouchdb-browser';
const db = new PouchDB('mydb');
```
