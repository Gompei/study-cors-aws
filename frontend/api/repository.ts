
import { NuxtAxiosInstance } from '@nuxtjs/axios'
import { AxiosResponse } from 'axios'

export interface CRUDActions {
    get<T>(): Promise<AxiosResponse<T>>,
    post<T>(): Promise<AxiosResponse<T>>,
}

export default (client: NuxtAxiosInstance) => (resource: string) => ({
  get<T> () {
    return client.get<T>(`api/${resource}`)
  },
  post<T> () {
    return client.post<T>(`api/${resource}`)
  }
})
