<template>
  <div class="container">
    <div class="navbar navbar-expand border-bottom">
      <router-link class="navbar-brand" to="/">DataX</router-link>
      <div class="ms-auto">
        <ul class="navbar-nav">
          <li class="nav-item">
            <router-link class="nav-link" to="/">{{ $t("navigations.home") }}</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link me-2" to="/user_list">{{ $t("navigations.user") }}</router-link>
          </li>
          <li class="nav-item">
            <select class="form-select" v-model="$i18n.locale">
              <option value="en">English</option>
              <option value="mm">Myanmar</option>
            </select>
          </li>
        </ul>
      </div>
    </div>
  </div>

</template>

<script>
export default {
  name: "nav-bar",
}
</script>