<template>
  <nav-bar></nav-bar>
  <div class="container my-4">
    <h3 class="text-center">
      {{ $t("headers.detail", { msg: "User" }) }}
    </h3>
    <user-show :user="user"></user-show>
  </div>
</template>

<script>
import NavBar from "@/components/NavBar.vue"
import UserShow from "@/components/users/UserShow.vue"
import axios from "axios"

export default {
  name: "UserDetails",
  components: {
    NavBar,
    UserShow
  },
  data() {
    return {
      userID: this.$route.params.id,
      user: {},
      base_url: "http://localhost:3000",
    }
  },
  methods: {
    getUser() {
      axios
        .get(this.base_url + '/api/users/' + this.userID)
        .then((response) => {
          this.user = response.data;
        })
        .catch((error) => console.log(error));
    }
  },
  mounted() {
    this.getUser();
  }
}
</script>