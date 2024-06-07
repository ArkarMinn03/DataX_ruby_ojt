<template>
  <nav-bar></nav-bar>
  <div class="container mt-3">
    <div class="text-center">
      <h4 class="d-inline-block">{{ $t("headers.list", { msg: "User" }) }}</h4>
      <button class="btn btn-sm btn-primary float-end" @click="addUser">
        {{ $t("buttons.common.add_new") }}
      </button>
    </div>
    <user-table :users="users" @userDeleted="getUsers"></user-table>
  </div>
</template>

<script>
import NavBar from "@/components/NavBar.vue"
import UserTable from "@/components/users/UserTable.vue"
import axios from "axios"
import router from "@/router"

export default {
  name: "UserList",
  components: {
    NavBar,
    UserTable
  },
  data() {
    return {
      users: [],
      base_url: "http://localhost:3000",
    }
  },
  methods: {
    getUsers() {
      axios
        .get(this.base_url + '/api/users')
        .then((response) => {
          this.users = response.data
        })
        .catch((error) => console.log(error));
    },
    addUser() {
      router.push("/user");
    }
  },
  mounted() {
    this.getUsers();
  }
}
</script>