import { it, expect, vi } from 'vitest';
import { mount, flushPromises } from '@vue/test-utils';
import Skills from '../../resources/js/pages/Skills.vue';
import Members from '../../resources/js/pages/Members.vue';
import DraftPlanEditor from '../../resources/js/components/DraftPlanEditor.vue';
function render(component, request, props = {}, role = 'administrator') {
    return mount(component, { props, global: { provide: { session: { state: { user: { id: 1, role } }, auth: { request } } }, stubs: { WorkspaceShell: { template: '<main><slot /></main>' }, RouterLink: { template: '<a><slot /></a>' } } } });
}
for (const component of [Skills, Members]) {
    it(component.__name + ' handles loading, error/retry, empty and populated states', async () => {
        let resolve;
        const request = vi.fn().mockImplementationOnce(() => new Promise(r => resolve = r)).mockRejectedValueOnce(new Error('Offline')).mockResolvedValueOnce({ data: [] }).mockResolvedValue({ data: [{ id: 4, name: 'Example', email: 'e@example.test', is_active: true }] });
        const w = render(component, request);
        expect(w.text()).toContain('Loading…'); resolve({ data: [] }); await flushPromises();
        expect(w.text()).toContain(component === Skills ? 'No matching skills' : 'No members found');
        // Changing a filter triggers a failure, then retry returns empty.
        if (component === Skills) await w.get('select').setValue('1');
        else await w.get('#member-filter').setValue('Example');
        await flushPromises(); expect(w.text()).toContain('Offline');
        await w.get('.state-error button').trigger('click'); await flushPromises();
        if (component === Skills) await w.get('select').setValue('');
        else await w.get('#member-filter').setValue('');
        await flushPromises(); expect(w.text()).toContain('Example'); w.unmount();
    });
}
it('skill creation guards duplicate requests and retains validation input', async () => {
    let reject;
    const request = vi.fn((path, options) => options ? new Promise((resolve, r) => reject = r) : Promise.resolve({ data: [] }));
    const w = render(Skills, request); await flushPromises();
    await w.get('#skill-name').setValue('Duplicate'); await w.get('form').trigger('submit'); await w.get('form').trigger('submit');
    expect(request.mock.calls.filter(c => c[1])).toHaveLength(1);
    reject({ message: 'Validation failed', details: { name: ['Name exists'] } }); await flushPromises();
    expect(w.text()).toContain('Name exists'); expect(w.get('#skill-name').element.value).toBe('Duplicate'); w.unmount();
});
it('skill edit supports retirement and displays conflict without clearing input', async () => {
    const request = vi.fn((path, options) => options ? Promise.reject({ message: 'Open week prevents retirement' }) : Promise.resolve({ data: [{ id: 4, name: 'Testing', is_active: true }] }));
    const w = render(Skills, request); await flushPromises();
    await w.get('article button').trigger('click'); await w.get('input[type=checkbox]').setValue(false);
    await w.get('form').trigger('submit'); await flushPromises();
    expect(JSON.parse(request.mock.calls.find(c => c[1])[1].body).is_active).toBe(false);
    expect(w.text()).toContain('Open week prevents retirement'); expect(w.get('#skill-name').element.value).toBe('Testing'); w.unmount();
});
it('members cannot see administration forms or request the member directory', async () => {
    const request = vi.fn().mockResolvedValue({ data: [] });
    const w = render(Members, request, {}, 'member'); await flushPromises();
    expect(request).not.toHaveBeenCalled(); expect(w.find('form').exists()).toBe(false); w.unmount();
    const s = render(Skills, request, {}, 'member'); await flushPromises();
    expect(s.find('form').exists()).toBe(false); s.unmount();
});
it('member corrections submit only identity fields', async () => {
    const request = vi.fn((path, options) => Promise.resolve(options ? { data: {} } : { data: [{ id: 2, name: 'Member', email: 'm@example.test' }] }));
    const w = render(Members, request); await flushPromises();
    await w.get('article button').trigger('click'); await w.get('#member-name').setValue('Corrected');
    await w.get('form').trigger('submit'); await flushPromises();
    expect(JSON.parse(request.mock.calls.find(c => c[1])[1].body)).toEqual({ name: 'Corrected', email: 'm@example.test' });
    expect(w.text()).toContain('Member updated'); w.unmount();
});
it('draft editing retains input on conflict and emits authoritative updates on success', async () => {
    const request = vi.fn().mockRejectedValueOnce({ message: 'Requires draft', details: {} }).mockResolvedValue({ data: { id: 5, key_gaps: 'Corrected', weekly_focus: 'Test' } });
    const w = render(DraftPlanEditor, request, { plan: { id: 5, key_gaps: 'Old', weekly_focus: 'Test' } });
    await w.get('#draft-gaps').setValue('Corrected'); await w.get('form').trigger('submit'); await flushPromises();
    expect(w.text()).toContain('Requires draft'); expect(w.get('#draft-gaps').element.value).toBe('Corrected');
    await w.get('form').trigger('submit'); await flushPromises();
    expect(w.emitted('saved')[0][0].key_gaps).toBe('Corrected'); w.unmount();
});
