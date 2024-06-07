<template>
  <div class="mt-3 mx-auto">
    <div class="border border-2 border-dark-50 rounded bg-light px-5 py-4">
      <table class="table table-light align-middle text-center">
        <thead class="text-uppercase border border-dark">
          <tr class="align-middle">
            <th scope="col" class="px-4 py-3">ID</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.common.name") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.user.email") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.user.gender") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.user.about_me") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.user.profile") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.common.created_at") }}</th>
            <th scope="col" class="px-4 py-3">{{ $t("labels.common.updated_at") }}</th>
            <th scope="col" class="px-4 py-3"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td class="px-2">{{ user.id }}</td>
            <td>
              <a href="#" class="text-black text-decoration-none" @click="viewDetail(user.id)">
                {{ user.first_name + " " + user.last_name }}
              </a>
            </td>
            <td>{{ user.email?.substring(0, 18) }}</td>
            <td>{{ user.gender }}</td>
            <td>{{ user.about_me?.substring(0, 18) }}</td>
            <td class="py-2">
              <img :src="user.image_url ? user.image_url : '/img-user-avator.png'" alt="user" class="img-thumbnail"
                style="width: 80px; height: auto;">
            </td>
            <td>{{ user.created_at }}</td>
            <td>{{ user.updated_at }}</td>
            <td>
              <button class="btn btn-success m-2" @click="editUser(user.id)">
                {{ $t("buttons.common.edit") }}
              </button>
              <button class="btn btn-danger" @click="deleteUser(user.id)">
                {{ $t("buttons.common.delete") }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import router from "@/router";

export default {
  name: "user-table",
  props: {
    users: Array
  },
  data() {
    return {
      base_url: "http://localhost:3000",
    }
  },
  methods: {
    editUser(userID) {
      router.push({ name: "user_edit", params: { id: userID } })
    },
    deleteUser(userID) {
      axios
        .delete(this.base_url + '/api/users/' + userID)
        .then(() => {
          console.log("User deleted successfully");
          this.$emit('userDeleted');
        })
        .catch((error) => console.log(error));
    },
    viewDetail(userID) {
      router.push({ name: "user_details", params: { id: userID } })
    }
  }
}
</script>