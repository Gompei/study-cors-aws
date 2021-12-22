import { NuxtConfig } from '@nuxt/types'

const nuxtConfig: NuxtConfig = {
  target: 'static',
  head: {
    title: 'frontend',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },
  css: [],
  plugins: [
    '@/plugins/repositoryFactory.ts'
  ],
  components: true,
  buildModules: [
    '@nuxt/typescript-build'
  ],
  modules: [
    '@nuxtjs/axios'
  ],
  axios: {
    baseURL: process.env.BASE_URL
  },
  build: {},
  router: {}
}

export default nuxtConfig
