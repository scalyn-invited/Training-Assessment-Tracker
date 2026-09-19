<script setup>
import { inject, reactive, ref } from 'vue';
const props = defineProps({ plan: Object }), emit = defineEmits(['saved']);
const { auth } = inject('session');
const form = reactive({ key_gaps: props.plan.key_gaps, weekly_focus: props.plan.weekly_focus });
const busy = ref(false), error = ref(''), errors = ref({}), notice = ref('');
async function save() {
    if (busy.value) return;
    busy.value = true; error.value = ''; errors.value = {}; notice.value = '';
    try { const result = await auth.request('/plans/' + props.plan.id, { method: 'PATCH', body: JSON.stringify(form) }); emit('saved', result.data); notice.value = 'Draft direction saved.'; }
    catch (e) { error.value = e.message + ' Your input is retained. Refresh if the plan has changed.'; errors.value = e.details || {}; }
    finally { busy.value = false; }
}
</script>
<template><section class="week-card"><h2>Edit draft direction</h2><p v-if="notice" class="notice" role="status">{{ notice }}</p><p v-if="error" class="error-box" role="alert">{{ error }}</p>
<form @submit.prevent="save" novalidate><fieldset :disabled="busy"><label for="draft-gaps">Key gaps</label><textarea id="draft-gaps" v-model="form.key_gaps" maxlength="2000"></textarea><small class="field-error">{{ errors.key_gaps?.[0] }}</small>
<label for="draft-focus">Weekly focus</label><textarea id="draft-focus" v-model="form.weekly_focus" maxlength="2000"></textarea><small class="field-error">{{ errors.weekly_focus?.[0] }}</small><button class="primary">{{ busy ? 'Saving…' : 'Save draft direction' }}</button></fieldset></form></section></template>
