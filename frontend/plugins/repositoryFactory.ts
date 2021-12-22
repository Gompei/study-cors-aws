import { Context } from '@nuxt/types'
import { Inject } from '@nuxt/types/app'
import createRepositories, { CRUDActions } from '@/api/repository'

export interface Repositories {
    clients: CRUDActions
}

export default (context: Context, inject: Inject) => {
  const repositoryWithAxios = createRepositories(context.$axios)
  const repositories = {
    clients: repositoryWithAxios('test')
  }
  inject('repositories', repositories)
}
