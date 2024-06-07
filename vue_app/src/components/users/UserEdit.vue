<template>
  <div class="mt-3 mx-auto" style="width: 800px">
    <div class="border border-dark-50 border-3 rounded bg-light px-5 py-4">
      <form @submit.prevent="updateUser">
        <div class="mb-3">
          <label class="form-label fw-bold" for="first_name">{{ $t("labels.user.first_name") }}</label>
          <input type="text" class="form-control" v-model="user.first_name" placeholder="Elsa" id="first_name">
          <span class="text-danger" style="font-size: small;">{{ first_name_errors }}</span>
        </div>
        <div class="mb-3">
          <label class="form-label fw-bold" for="last_name">
            {{ $t("labels.user.last_name") }}
          </label>
          <input type="text" class="form-control" v-model="user.last_name" placeholder="Mamacita" id="last_name">
          <span class="text-danger" style="font-size: small;">{{ last_name_errors }}</span>
        </div>
        <div class="mb-3">
          <label class="form-label fw-bold" for="email">{{ $t("labels.user.email") }}</label>
          <input type="email" class="form-control" v-model="user.email" placeholder="elsa@gmail.com" id="email">
          <span class="text-danger" style="font-size: small;">{{ email_errors }}</span>
        </div>
        <div class="mb-3">
          <label class="form-label fw-bold" for="about_me">{{ $t("labels.user.about_me") }}</label>
          <input type="text" class="form-control" v-model="user.about_me" placeholder="Everyday Normal Dude"
            id="about_me">
          <span class="text-danger" style="font-size: small;">{{ about_me_errors }}</span>
        </div>
        <div class="mb-3">
          <label class="form-label fw-bold d-block">{{ $t("labels.user.gender") }}</label>
          <div class="form-check me-5 d-inline-block">
            <input type="radio" class="form-check-input" value="0" v-model="user.gender" id="male"
              :checked="user.gender === 'Male'">
            <label for="male" class="form-check-label">Male</label>
          </div>
          <div class="form-check d-inline-block">
            <input type="radio" class="form-check-input" value="2" v-model="user.gender" id="female"
              :checked="user.gender === 'Female'">
            <label for="female" class="form-check-label">Female</label>
          </div>
          <span class="text-danger" style="font-size: small;">{{ gender_errors }}</span>
        </div>
        <div class="d-flex justify-content-center">
          <button class="btn btn-success me-2">{{ $t("buttons.common.update") }}</button>
          <button type="reset" class="btn btn-danger">{{ $t("buttons.common.cancel") }}</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import axios from "axios"
import router from "@/router"

export default {
  name: "user-edit",
  data() {
    return {
      base_url: "http://localhost:3000",
      // base_url: import.meta.env.VUE_APP_API_BASE_URL,

      first_name_errors: null,
      last_name_errors: null,
      email_errors: null,
      about_me_errors: null,
      gender_errors: null,
      userID: this.$route.params.id,

      user: {
        first_name: "",
        last_name: "",
        email: "",
        about_me: "",
        gender: null,
      }
    }
  },
  methods: {
    getUser(userID) {
      axios
        .get(this.base_url + `/api/users/` + userID)
        .then((response) => {
          this.user = response.data;
        })
        .catch((error) => console.log(error));
    },
    updateUser() {
      this.first_name_errors = null;
      this.last_name_errors = null;
      this.email_errors = null;
      this.about_me_errors = null;
      this.gender_errors = null;

      let formData = new FormData();
      formData.append("user[first_name]", this.user.first_name);
      formData.append("user[last_name]", this.user.last_name);
      formData.append("user[email]", this.user.email);
      formData.append("user[about_me]", this.user.about_me);
      formData.append("user[gender]", this.user.gender);

      axios
        .put(this.base_url + `/api/users/` + this.userID, formData)
        .then((response) => {
          if (response.data.status == "updated") {
            router.push("/user_list");
            console.log("User successfully updated.");
          }
        })
        .catch((error) => {
          if (error.response.data.status !== "updated") {
            const fields = [
              "first_name",
              "last_name",
              "email",
              "about_me",
              "gender"
            ];

            fields.forEach((field) => {
              if (error.response.data[field]) {
                this[`${field}_errors`] = error.response.data[field][0];
              }
            });
          }
        });

    }
  },
  mounted() {
    this.getUser(this.userID)
  }
}
</script>