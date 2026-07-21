(() => {
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  
    const createAutoRotator = ({
      steps,
      getCurrentStep,
      activate,
      getDelay,
      canRun = () => true,
      controls,
      onPauseChange
    }) => {
      let timer;
      let paused = false;
  
      const stop = () => window.clearTimeout(timer);
  
      const schedule = () => {
        stop();
        if (reducedMotion || paused || !canRun()) return;
  
        const currentStep = getCurrentStep();
        timer = window.setTimeout(() => {
          const currentIndex = Math.max(0, steps.indexOf(currentStep));
          activate(steps[(currentIndex + 1) % steps.length]);
          schedule();
        }, getDelay(currentStep));
      };
  
      const setPaused = nextPaused => {
        paused = nextPaused;
        onPauseChange?.(paused);
        if (paused) stop();
        else schedule();
      };
  
      controls?.addEventListener("pointerenter", () => setPaused(true));
      controls?.addEventListener("pointerleave", () => setPaused(false));
      controls?.addEventListener("focusin", () => setPaused(true));
      controls?.addEventListener("focusout", event => {
        if (!controls.contains(event.relatedTarget)) setPaused(false);
      });
  
      return { schedule, stop };
    };
  
    window.Mealchemy = { reducedMotion, createAutoRotator };
  })();
  