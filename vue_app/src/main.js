import { createApp } from 'vue'
import App from './App.vue'
import i18n from './i18n'
import router from './router'
import '../node_modules/bootstrap/dist/css/bootstrap.min.css'
import '../node_modules/bootstrap/dist/js/bootstrap.bundle.min.js'

createApp(App).use(router).use(i18n).mount('#app')