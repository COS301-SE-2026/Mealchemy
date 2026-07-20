(() => {
    const root = document.documentElement;
    const meter = document.querySelector(".scroll-meter span");
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    
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
    
    
    
    const counters = document.querySelectorAll("[data-count]");
    const countObserver = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          const target = Number(entry.target.dataset.count);
          const duration = 950;
          const start = performance.now();
    
          const tick = now => {
            const progress = Math.min((now - start) / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            entry.target.textContent = Math.round(target * eased);
            if (progress < 1) requestAnimationFrame(tick);
          };
    
          requestAnimationFrame(tick);
          countObserver.unobserve(entry.target);
        });
      },
      { threshold: 0.6 }
    );
    
    counters.forEach(counter => countObserver.observe(counter));
    
    
    
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
    })();
    