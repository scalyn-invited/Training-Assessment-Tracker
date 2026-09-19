<script setup>
import { inject, ref, reactive } from 'vue';
import WorkspaceShell from '../components/WorkspaceShell.vue';
import ScreenState from '../components/ScreenState.vue';
import Pagination from '../components/Pagination.vue';
import { useResource } from '../use-resource';
const { state, auth } = inject('session');
const page = ref(1), active = ref(''), selected = ref(null), busy = ref(false), error = ref(''), errors = ref({}), notice = ref('');
const form = reactive({ name: '', description: '', is_active: true });
const { data, loading, error: loadError, load } = useResource(() => '/skills?per_page=10&page=' + page.value + (active.value === '' ? '' : '&active=' + active.value), auth.request);
function edit(skill) { selected.value = skill?.id ?? null; Object.assign(form, { name: skill?.name ?? '', description: skill?.description ?? '', is_active: skill?.is_active ?? true }); error.value = ''; errors.value = {}; }
async function save() {
    if (busy.value) return;
    busy.value = true; error.value = ''; errors.value = {}; notice.value = '';
    try {
        await auth.request('/skills' + (selected.value ? '/' + selected.value : ''), { method: selected.value ? 'PATCH' : 'POST', body: JSON.stringify(selected.value ? form : { name: form.name, description: form.description }) });
        edit(null); notice.value = 'Skill saved.'; await load();
    } catch (e) { errors.value = e.details || {}; error.value = e.message + ' Input retained. Refresh before retrying a timed-out request.'; }
    finally { busy.value = false; }
}
</script>
<template><WorkspaceShell>
<div class="page-heading"><div><span class="section-number">THE BUILDING BLOCKS</span><h1>Skills<span class="green">.</span></h1><p class="muted">Manage the catalogue without losing historical assessments.</p></div></div>
<p v-if="notice" class="notice" role="status">{{ notice }}</p>
<section v-if="state.user?.role === 'administrator'" class="week-card"><h2>{{ selected ? 'Edit skill' : 'Create skill' }}</h2>
<p v-if="error" class="error-box" role="alert">{{ error }}</p>
<form @submit.prevent="save" novalidate><fieldset :disabled="busy">
<label for="skill-name">Name</label><input id="skill-name" v-model="form.name" maxlength="255"><small class="field-error">{{ errors.name?.[0] }}</small>
<label for="skill-description">Description</label><textarea id="skill-description" v-model="form.description" maxlength="2000"></textarea><small class="field-error">{{ errors.description?.[0] }}</small>
<label v-if="selected" class="confirm-line"><input type="checkbox" v-model="form.is_active">Active — uncheck to retire</label>
<p class="muted">Skills are never deleted. Retirement is refused while the skill has an open week. Existing assessments remain visible.</p>
<button class="primary" type="submit">{{ busy ? 'Saving…' : 'Save skill' }}</button><button v-if="selected" class="text-button" type="button" @click="edit(null)">Cancel editing</button>
</fieldset></form></section>
<section class="week-card"><div class="toolbar"><h2>Catalogue</h2><label>Status <select v-model="active" @change="page = 1"><option value="">All</option><option value="1">Active</option><option value="0">Retired</option></select></label></div>
<ScreenState :loading="loading" :error="loadError" :empty="!data?.data?.length" title="No matching skills" @retry="load">
<article v-for="skill in data?.data" :key="skill.id" class="baseline-review"><div><strong>{{ skill.name }}</strong><p class="muted">{{ skill.description }}</p></div><span class="status-tag">{{ skill.is_active ? 'Active' : 'Retired' }}</span><button v-if="state.user?.role === 'administrator'" class="secondary" :disabled="busy" @click="edit(skill)">Edit skill</button></article>
</ScreenState><Pagination :meta="data?.meta" :busy="loading || busy" @page="page = $event" /></section>
</WorkspaceShell></template>
