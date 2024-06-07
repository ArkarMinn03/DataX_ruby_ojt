<template>
  <nav-bar></nav-bar>
  <div class="container my-4">
    <h3 class="text-center">{{ $t("headers.register_form", { msg: "User" }) }}</h3>
    <user-create></user-create>
  </div>
</template>

<script>
import UserCreate from '@/components/users/UserCreate.vue'
import NavBar from '@/components/NavBar.vue'

export default {
  name: 'UserCreateForm',
  components: {
    NavBar,
    UserCreate
  }
}
</script>