import { Repositories } from '@/plugins/repositoryFactory'

declare module 'vue/types/vue' {
    interface Vue {
      $repositories: Repositories
    }
}

declare module '@nuxt/types' {
  interface Context {
    $repositories: Repositories
  }
}
