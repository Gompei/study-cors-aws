<template>
  <div>
    {{ getData }}<br>
    {{ postData }}
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'nuxt-property-decorator'

@Component
export default class Index extends Vue {
  private getData: any = ''
  private postData: any = ''

  mounted () {
    this.get()
    this.post()
  }

  async get () {
    const response = await this.$repositories.clients.get()
    this.getData = response.data
  }

  async post () {
    const response = await this.$repositories.clients.post()
    this.postData = response.data
  }
}
</script>
