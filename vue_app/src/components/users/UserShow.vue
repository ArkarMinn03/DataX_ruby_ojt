<template>
  <div class="mt-3 mx-auto" style="width: 800px;">
    <div class="border border-2 border-dark-50 rounded bg-light px-5 py-4">
      <img :src="user.image_url ? user.image_url : '/img-user-avator.png'" alt="User Profile" class="img-thumbnail mb-3"
        style="width: 200px; height: auto;">
      <table class="table table-light">
        <tbody>
          <tr>
            <td class="py-3 col-4">{{ $t("labels.user.first_name") }}</td>
            <td class="py-3 col-8">{{ user.first_name }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.user.last_name") }}</td>
            <td class="py-3">{{ user.last_name }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.user.email") }}</td>
            <td class="py-3">{{ user.email }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.user.gender") }}</td>
            <td class="py-3">{{ user.gender }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.user.about_me") }}</td>
            <td class="py-3">{{ user.about_me }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.common.created_at") }}</td>
            <td class="py-3">{{ user.created_at }}</td>
          </tr>
          <tr>
            <td class="py-3">{{ $t("labels.common.updated_at") }}</td>
            <td class="py-3">{{ user.updated_at }}</td>
          </tr>
        </tbody>
      </table>
      <div class="d-flex justify-content-center">
        <button class="btn btn-warning me-2" @click="viewList">
          {{ $t("buttons.common.view_list") }}
        </button>
        <button class="btn btn-success me-2" @click="editUser">
          {{ $t("buttons.common.edit") }}
        </button>
        <button class="btn btn-danger" @click="deleteUser">
          {{ $t("buttons.common.delete") }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import router from "@/router"

export default {
  name: "user-show",
  props: {
    user: Object,
  },
  data() {
    return {
      base_url: "http://localhost:3000",
    }
  },
  methods: {
    deleteUser() {
      axios
        .delete(this.base_url + '/api/users/' + this.user.id)
        .then(() => {
          console.log("User was successfully deleted.");
          router.push("/");
        })
        .catch((error) => console.log(error));
    },
    editUser() {
      router.push({ name: "user_edit", params: { id: this.user.id } });
    },
    viewList() {
      router.push("/user_list");
    }

  }
}
</script>