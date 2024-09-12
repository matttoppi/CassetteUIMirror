{{flutter_js}}
{{flutter_build_config}}

window.addEventListener('load', function(ev) {
  console.log('Initializing Flutter');
  _flutter.loader.load({
    serviceWorkerSettings: {
      serviceWorkerVersion: '{{flutter_service_worker_version}}',
    },
    onEntrypointLoaded: async function(engineInitializer) {
      console.log('Flutter entrypoint loaded');
      const appRunner = await engineInitializer.initializeEngine();
      console.log('Flutter engine initialized');
      await appRunner.runApp();
      console.log('Flutter app running');
    }
  });
});

