{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({ renderer: "html" });
    await appRunner.runApp();

    // Smooth fade out of the HTML loader
    const loader = document.querySelector('#loader-content');
    if (loader) {
      loader.style.opacity = '0';
      setTimeout(() => loader.remove(), 400);
    }
  }
});