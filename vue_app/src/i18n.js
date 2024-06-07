import { createI18n } from 'vue-i18n';
import en from './locales/en.json';
import mm from './locales/mm.json';

function loadLocalMessages() {
  const locales = [{ en: en }, { mm: mm }];
  const messages = {}
  locales.forEach((lang) => {
    const key = Object.keys(lang);
    messages[key] = lang[key]
  });
  return messages;
}

export default createI18n({
  locale: "en",
  messages: loadLocalMessages()
});