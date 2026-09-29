(() => {
    const root = document.documentElement;
  
    const updateScroll = () => {
      const max = document.body.scrollHeight - window.innerHeight;
      const progress = max > 0 ? (window.scrollY / max) * 100 : 0;
      root.style.setProperty("--scroll", `${progress}%`);
    };
  
    window.addEventListener("scroll", updateScroll, { passive: true });
    updateScroll();
  
    const revealObserver = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add("visible");
            revealObserver.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.15 }
    );
  
    document.querySelectorAll(".reveal").forEach(element => revealObserver.observe(element));
  
    document.querySelectorAll("[data-tilt]").forEach(card => {
      card.addEventListener("pointermove", event => {
        const rect = card.getBoundingClientRect();
        const x = event.clientX - rect.left;
        const y = event.clientY - rect.top;
        const rotateY = ((x / rect.width) - 0.5) * 8;
        const rotateX = ((0.5 - y / rect.height)) * 8;
        card.style.transform = `perspective(900px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-4px)`;
      });
  
      card.addEventListener("pointerleave", () => {
        card.style.transform = "";
      });
    });
  
    document.querySelectorAll(".magnetic").forEach(button => {
      button.addEventListener("pointermove", event => {
        const rect = button.getBoundingClientRect();
        const x = event.clientX - rect.left - rect.width / 2;
        const y = event.clientY - rect.top - rect.height / 2;
        button.style.transform = `translate(${x * 0.08}px, ${y * 0.12}px) translateY(-3px)`;
      });
  
      button.addEventListener("pointerleave", () => {
        button.style.transform = "";
      });
    });
  
    document.querySelectorAll("[data-placeholder-link]").forEach(link => {
      link.addEventListener("click", event => {
        event.preventDefault();
        link.animate(
          [
            { transform: "translateY(0)" },
            { transform: "translateY(-6px)" },
            { transform: "translateY(0)" }
          ],
          { duration: 360, easing: "ease-out" }
        );
      });
    });
    const bonusTrack = document.querySelector("[data-bonus-track]");
  const bonusButtons = Array.from(document.querySelectorAll("[data-bonus-scroll]"));

  if (bonusTrack && bonusButtons.length) {
    const updateBonusControls = () => {
      const atStart = bonusTrack.scrollLeft <= 4;
      const atEnd = bonusTrack.scrollLeft + bonusTrack.clientWidth >= bonusTrack.scrollWidth - 4;

      bonusButtons.forEach(button => {
        button.disabled = button.dataset.bonusScroll === "previous" ? atStart : atEnd;
      });
    };

    bonusButtons.forEach(button => {
      button.addEventListener("click", () => {
        const direction = button.dataset.bonusScroll === "previous" ? -1 : 1;
        const distance = Math.min(bonusTrack.clientWidth * 0.82, 610);
        bonusTrack.scrollBy({ left: direction * distance, behavior: "smooth" });
      });
    });

    bonusTrack.addEventListener("scroll", updateBonusControls, { passive: true });
    window.addEventListener("resize", updateBonusControls);
    updateBonusControls();
  }
})();
  
  