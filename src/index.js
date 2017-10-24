import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import '../public/vendor/bootstrap/css/bootstrap.css';

Main.embed(document.getElementById('root'));

registerServiceWorker();
