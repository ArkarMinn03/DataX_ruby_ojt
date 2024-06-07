<template>
  <nav-bar></nav-bar>
  <div class="container mt-4">
    <h3 class="text-center">
      {{ $t("headers.update_form", { msg: "User" }) }}
    </h3>
    <user-edit></user-edit>
  </div>

</template>

<script>
import NavBar from "@/components/NavBar.vue"
import UserEdit from "@/components/users/UserEdit.vue"

export default {
  name: "UserEditForm",
  components: {
    NavBar,
    UserEdit
  }
}
</script>