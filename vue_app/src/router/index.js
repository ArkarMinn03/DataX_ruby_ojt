import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import UserCreateForm from '../views/users/UserCreateForm.vue'
import UserEditForm from '../views/users/UserEditForm.vue'
import UserDetails from '@/views/users/UserDetails.vue';
import UserList from '@/views/users/UserList.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/user_list',
    name: 'user_list',
    component: UserList
  },
  {
    path: '/user',
    name: 'user',
    component: UserCreateForm
  },
  {
    path: '/user_details/:id',
    name: 'user_details',
    component: UserDetails
  },
  {
    path: '/user_edit/:id',
    name: 'user_edit',
    component: UserEditForm
  }
];


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
