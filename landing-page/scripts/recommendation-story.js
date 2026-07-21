(() => {
    const learningPanel = document.querySelector(".learning-reveal");
  
    if (learningPanel) {
      const learningObserver = new IntersectionObserver(
        entries => {
          entries.forEach(entry => {
            if (!entry.isIntersecting) return;
  
            entry.target.classList.add("visible");
            learningObserver.unobserve(entry.target);
          });
        },
        {
          threshold: 0.22,
          rootMargin: "0px 0px -8% 0px"
        }
      );
  
      learningObserver.observe(learningPanel);
    }
  
    const engineDemo = document.querySelector(".heuristic-demo[data-engine-state]");
    const engineButtons = Array.from(document.querySelectorAll("[data-engine-phase]"));
    const enginePhasePills = Array.from(document.querySelectorAll(".heuristic-demo .phase-strip span"));
    const engineVisualLayer = document.querySelector(".phase-visual-layer");
    const engineCandidateBank = document.querySelector(".heuristic-demo .candidate-bank");
  
    if (engineDemo && engineButtons.length && engineVisualLayer && engineCandidateBank) {
      const enginePhases = ["vault", "filter", "tournament", "score", "allocation", "swipe", "learn"];
      const engineDurations = {
        vault: 5000,
        filter: 6500,
        tournament: 5500,
        score: 8500,
        allocation: 8000,
        swipe: 8500,
        learn: 7500
      };
      const pillByPhase = {
        vault: 0,
        filter: 1,
        tournament: 2,
        score: 3,
        allocation: 4,
        swipe: 4,
        learn: 4
      };
      let engineInView = false;
      const engineControls = engineDemo.querySelector(".phase-card-stack");
  
      engineVisualLayer.prepend(engineCandidateBank);
  
      const replayEnginePhase = phase => {
        if (!enginePhases.includes(phase)) return;
  
        engineDemo.dataset.engineState = phase;
        engineButtons.forEach(button => {
          const isActive = button.dataset.enginePhase === phase;
          button.classList.toggle("is-active", isActive);
          button.setAttribute("aria-pressed", String(isActive));
        });
  
        enginePhasePills.forEach((pill, index) => {
          pill.classList.toggle("is-active", index === pillByPhase[phase]);
        });
  
        engineDemo.classList.remove("phase-replay");
        void engineDemo.offsetWidth;
        engineDemo.classList.add("phase-replay");
      };
  
      const engineRotator = window.Mealchemy.createAutoRotator({
        steps: enginePhases,
        getCurrentStep: () => engineDemo.dataset.engineState,
        activate: replayEnginePhase,
        getDelay: phase => engineDurations[phase] || 6500,
        canRun: () => engineInView,
        controls: engineControls
      });
  
      engineButtons.forEach(button => {
        button.addEventListener("click", () => {
          replayEnginePhase(button.dataset.enginePhase);
          engineRotator.schedule();
        });
      });
  
      const engineObserver = new IntersectionObserver(
        entries => {
          entries.forEach(entry => {
            engineInView = entry.isIntersecting;
            if (engineInView) {
              engineRotator.schedule();
            } else {
              engineRotator.stop();
            }
          });
        },
        { threshold: 0.2 }
      );
  
      replayEnginePhase("vault");
      engineObserver.observe(engineDemo);
    }
  })();
  
  