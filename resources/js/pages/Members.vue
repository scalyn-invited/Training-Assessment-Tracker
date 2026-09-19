<script setup>
import { inject, ref, reactive } from 'vue';
import WorkspaceShell from '../components/WorkspaceShell.vue';
import ScreenState from '../components/ScreenState.vue';
import { useResource } from '../use-resource';
const { state, auth } = inject('session');
const page = ref(1), search = ref(''), selected = ref(null), busy = ref(false), error = ref(''), errors = ref({}), notice = ref('');
const form = reactive({ name: '', email: '' });
const { data, loading, error: loadError, load } = useResource(() => '/members?page=' + page.value + '&search=' + encodeURIComponent(search.value), path => state.user?.role === 'administrator' ? auth.request(path) : Promise.resolve({ data: [] }));
function edit(member) { selected.value = member.id; form.name = member.name; form.email = member.email; errors.value = {}; error.value = ''; }
async function save() {
    if (busy.value) return;
    busy.value = true; error.value = ''; errors.value = {};
    try { await auth.request('/members/' + selected.value, { method: 'PATCH', body: JSON.stringify(form) }); selected.value = null; notice.value = 'Member updated.'; await load(); }
    catch (e) { error.value = e.message; errors.value = e.details || {}; }
    finally { busy.value = false; }
}
</script>
<template><WorkspaceShell><div class="page-heading"><div><span class="section-number">YOUR PROGRAMME</span><h1>Members<span class="green">.</span></h1></div></div>
<p v-if="state.user?.role !== 'administrator'" class="notice">Only administrators can manage members.</p>
<template v-else><p class="notice">New members create their own account at <RouterLink to="/register">member registration</RouterLink>. Passwords and administrator roles are not managed here.</p>
<p v-if="notice" class="notice" role="status">{{ notice }}</p>
<form v-if="selected" class="week-card" @submit.prevent="save" novalidate><h2>Edit member</h2><p v-if="error" class="error-box" role="alert">{{ error }}</p><fieldset :disabled="busy">
<label for="member-name">Name</label><input id="member-name" v-model="form.name"><small class="field-error">{{ errors.name?.[0] }}</small>
<label for="member-email">Sign-in email</label><input id="member-email" v-model="form.email" type="email"><small class="field-error">{{ errors.email?.[0] }}</small><p class="muted">Changing this address changes the member's sign-in email. Tell the member before changing it.</p>
<button class="primary">Save member</button><button type="button" class="text-button" @click="selected = null">Cancel</button></fieldset></form>
<section class="week-card"><label for="member-filter">Search names</label><input id="member-filter" v-model="search" @input="page = 1">
<ScreenState :loading="loading" :error="loadError" :empty="!data?.data?.length" title="No members found" @retry="load">
<article v-for="member in data?.data" :key="member.id" class="baseline-review"><div><strong>{{ member.name }}</strong><p class="muted">{{ member.email }} · {{ member.development_plans_count }} {{ member.development_plans_count === 1 ? 'cycle' : 'cycles' }}</p></div><RouterLink v-if="member.development_plan" :to="'/plans/' + member.development_plan.id">View cycle {{ member.development_plan.cycle_number }} · {{ member.development_plan.status }}</RouterLink><RouterLink v-if="!member.development_plan || member.development_plan.status === 'completed'" to="/plans/new">{{ member.development_plan ? 'Start next cycle' : 'Assign first plan' }}</RouterLink><button class="secondary" :disabled="busy" @click="edit(member)">Edit member</button></article>
</ScreenState><div class="form-actions"><button class="secondary" :disabled="page === 1 || loading" @click="page--">Previous</button><span>Page {{ page }}</span><button class="secondary" :disabled="!data?.next_page_url || loading" @click="page++">Next</button></div></section></template>
</WorkspaceShell></template>
