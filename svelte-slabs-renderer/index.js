/**
 * Find props for a slab based on the given propstring
 * @param  {String} propString String defining where to locate the svelte props
 * @return {Object}            Props ready to pass to svelte
 */
const resolveProps = async (propString, baseUrl) => {
	if (!propString) return {};
	const [src, key] = propString.split(':');
	if (src === 'window') {
		if (!window.svelteSlabs) return {};
		return window.svelteSlabs[key] || {};
	} else if (src === 'window_b') {
		if (!window.svelteSlabs) return {};
		let slabData = {};
		try {
			slabData = JSON.parse(atob(window.svelteSlabs[key]));
		} catch(e) {
			console.error("Svelte slab rendering error:");
			console.error(e);
		}
		return slabData;
	} else if (src === 'window_e') {
		if (!window.svelteSlabs) return {};
		let slabData = {};
		try {
			slabData = JSON.parse(window.svelteSlabs[key].replace(/&rawlt;/g, "<"));
		} catch(e) {
			console.error("Svelte slab rendering error:");
			console.error(e);
		}
		return slabData;
	} else if (src === 'endpoint') {
		let slabData = {};
		try {
			baseUrl = baseUrl.replace(/\/$/, '');
			const slabReq = await fetch(`${baseUrl}/_slabs/${key}.json`);
			slabData = await slabReq.json();
		} catch(e) {
			console.error("Svelte slab endpoint rendering error:");
			console.error(e);
		}
		return slabData;
	}
}

/**
 * Look for svelte tags on the page, and try render an app into them.
 * @param  {Object} apps    All svelte components available, keyed by name
 * @return {Object}         All svelte apps that were rendered on the page
 */
export const renderSlabs = async (apps, opts) => {
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
			const slabProps = await resolveProps(slabPropsKey, baseUrl);
			if (typeof opts.transformProps === 'function') {
				opts.transformProps(slabProps, target);
			}

			renderedSlabs.push(new app({target, props: slabProps, hydrate: opts.hydrate}));
		} else {
			console.warn(`WARN: Svelte slab "${slabName}" not found`)
		}
	}

	return renderedSlabs;
}