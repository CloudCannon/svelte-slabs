/**
 * Find props for a slab based on the given propstring
 * @param  {String} propString String defining where to locate the svelte props
 * @return {Object}            Props ready to pass to svelte
 */
const resolveProps = (propString) => {
	if (!propString) return {};
	const [src, key] = propString.split(':');
	if (src === 'window') {
		if (!window.svelteSlabs) return {};
		return window.svelteSlabs[key] || {};
	} else if (src === 'endpoint') {
		console.warn('Endpoints not yet supported');
		return {};
	}
}

/**
 * Look for svelte tags on the page, and try render an app into them.
 * @param  {Object} apps    All svelte components available, keyed by name
 * @return {Object}         All svelte apps that were rendered on the page
 */
export const renderSlabs = (apps, opts) => {
	opts = {
		hydrate: true,
		...opts
	}

	const renderTargets = document.querySelectorAll("[data-svelte-slab]");
	const renderedSlabs = [];

	for (const target of renderTargets) {
		const slabName = target.dataset.svelteSlab;
		const slabPropsKey = target.dataset.svelteSlabProps;

		const app = apps[slabName];
		if (app) {
			const slabProps = resolveProps(slabPropsKey);

			renderedSlabs.push(new app({target, props: slabProps, hydrate: opts.hydrate}));
		} else {
			console.warn(`WARN: Svelte slab "${slabName}" not found`)
		}
	}

	return renderedSlabs;
}