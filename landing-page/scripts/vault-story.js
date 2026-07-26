(() => {
    const vaultExplainer = document.querySelector(".vault-explainer[data-vault-scene]");
    const vaultSceneButtons = Array.from(document.querySelectorAll("[data-vault-step]"));
    const vaultScenePanels = Array.from(document.querySelectorAll("[data-vault-scene-panel]"));
  
    if (vaultExplainer && vaultSceneButtons.length && vaultScenePanels.length) {
      const vaultScenes = ["private", "add", "shared", "invite", "protect", "global", "copy"];
      const vaultSceneDuration = 7200;
      let vaultSceneInView = false;
  
      const showVaultScene = scene => {
        if (!vaultScenes.includes(scene)) return;
  
        vaultExplainer.dataset.vaultScene = scene;
        vaultSceneButtons.forEach(button => {
          const isActive = button.dataset.vaultStep === scene;
          button.classList.toggle("is-active", isActive);
          button.setAttribute("aria-pressed", String(isActive));
        });
  
        vaultScenePanels.forEach(panel => panel.classList.remove("is-active"));
        const activePanel = vaultScenePanels.find(panel => panel.dataset.vaultScenePanel === scene);
        if (!activePanel) return;
  
        void vaultExplainer.offsetWidth;
        activePanel.classList.add("is-active");
      };
  
      const vaultControls = vaultExplainer.querySelector(".vault-scene-controls");
      const vaultRotator = window.Mealchemy.createAutoRotator({
        steps: vaultScenes,
        getCurrentStep: () => vaultExplainer.dataset.vaultScene,
        activate: showVaultScene,
        getDelay: () => vaultSceneDuration,
        canRun: () => vaultSceneInView,
        controls: vaultControls
      });
  
      vaultSceneButtons.forEach(button => {
        button.addEventListener("click", () => {
          showVaultScene(button.dataset.vaultStep);
          vaultRotator.schedule();
        });
      });
  
      const vaultSceneObserver = new IntersectionObserver(
        entries => {
          entries.forEach(entry => {
            vaultSceneInView = entry.isIntersecting;
            if (vaultSceneInView) {
              vaultRotator.schedule();
            } else {
              vaultRotator.stop();
            }
          });
        },
        { threshold: 0.18 }
      );
  
      showVaultScene("private");
      vaultSceneObserver.observe(vaultExplainer);
    }
  })();
  
  