(() => {
    const screens = {
      dashboard: {
        image: "assets/screens/app-dashboard.jpg",
        alt: "Real Mealchemy dashboard screen",
        kicker: "Dashboard · Live app",
        title: "A calm command centre for cooking decisions.",
        copy: "The dashboard surfaces pantry status, smart suggestions, recommended recipes, and trending ideas without overwhelming the user.",
        live: true,
        aspectRatio: "392 / 850"
      },
      swipe: {
        image: "assets/screens/app-guided-discovery.jpg",
        alt: "Real Mealchemy guided discovery swipe screen",
        kicker: "Guided Discovery · Live app",
        title: "A fast, playful answer to choice overload.",
        copy: "Swipe interactions let users like, reject, and refine recommendations while the system learns their cooking preferences.",
        live: true,
        aspectRatio: "392 / 850"
      },
      pantry: {
        image: "assets/screens/app-pantry.jpg",
        alt: "Real Mealchemy pantry inventory screen",
        kicker: "Pantry · Live app",
        title: "Ingredient awareness before recipe commitment.",
        copy: "Pantry inventory and freshness states help Mealchemy recommend what users can make now and what they need to buy.",
        live: true,
        aspectRatio: "392 / 850"
      },
      recipe: {
        image: "assets/screens/Recipe-Intstructions-page-real-app.jpg",
        alt: "Real Mealchemy recipe instructions screen",
        kicker: "Recipe · Live app",
        title: "Step-by-step cooking with full ingredient detail.",
        copy: "Recipe pages surface ingredients, quantities, nutritional breakdown, and step-by-step instructions so the user can cook without switching apps.",
        live: true,
        aspectRatio: "392 / 850"
      },
      shopping: {
        image: "assets/screens/Shopping-List-Real-app.jpg",
        alt: "Real Mealchemy shopping list screen",
        kicker: "Shopping Lists · Live app",
        title: "Recipe decisions become practical grocery lists.",
        copy: "Shopping lists organise favourites, general groceries, and recipe-specific ingredients so the user can move from meal choice to action.",
        live: true,
        aspectRatio: "392 / 850"
      }
    };
    const tabs = document.querySelectorAll(".screen-tab");
    const showcaseControls = document.querySelector(".showcase-controls");
    const activeImage = document.querySelector("#active-screen");
    const screenKicker = document.querySelector("#screen-kicker");
    const screenTitle = document.querySelector("#screen-title");
    const screenCopy = document.querySelector("#screen-copy");
    const screenKeys = Array.from(tabs).map(tab => tab.dataset.screen);
    const autoRotateDelay = 5000;
  
    const setActiveScreen = screenKey => {
      const selected = screens[screenKey];
      const activeTab = Array.from(tabs).find(tab => tab.dataset.screen === screenKey);
      if (!selected || !activeTab) return;
  
      tabs.forEach(item => {
        item.classList.remove("active");
        item.setAttribute("aria-selected", "false");
      });
  
      activeTab.classList.add("active");
      activeTab.setAttribute("aria-selected", "true");
  
      activeImage.animate(
        [
          { opacity: 1, transform: "scale(1)" },
          { opacity: 0, transform: "scale(0.985)" }
        ],
        { duration: 120, easing: "ease-out" }
      ).onfinish = () => {
        activeImage.src = selected.image;
        activeImage.alt = selected.alt;
        const phone = activeImage.closest(".phone");
        phone?.classList.toggle("uses-live-frame", selected.live);
        if (phone) phone.style.aspectRatio = selected.aspectRatio;
        screenKicker.textContent = selected.kicker;
        screenTitle.textContent = selected.title;
        screenCopy.textContent = selected.copy;
        activeImage.animate(
          [
            { opacity: 0, transform: "scale(1.015)" },
            { opacity: 1, transform: "scale(1)" }
          ],
          { duration: 220, easing: "ease-out" }
        );
      };
    };
  
    const showcaseRotator = window.Mealchemy.createAutoRotator({
      steps: screenKeys,
      getCurrentStep: () => document.querySelector(".screen-tab.active")?.dataset.screen,
      activate: setActiveScreen,
      getDelay: () => autoRotateDelay,
      controls: showcaseControls,
      onPauseChange: paused => showcaseControls?.classList.toggle("paused", paused)
    });
  
    tabs.forEach(tab => {
      tab.addEventListener("click", () => {
        setActiveScreen(tab.dataset.screen);
        showcaseRotator.schedule();
      });
    });
  
    showcaseRotator.schedule();
  })();
  
  