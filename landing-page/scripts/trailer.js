(() => {
    const video = document.querySelector(".trailer-video");
    if (!video) return;
  
    const motionPreference = window.matchMedia("(prefers-reduced-motion: reduce)");
    const connection = navigator.connection;
    let inView = false;
    let userPaused = false;
    let automaticPause = false;
  
    const pauseOutsideView = () => {
      if (video.paused) return;
      automaticPause = true;
      video.pause();
    };
  
    const updatePlayback = () => {
      if (!inView || document.hidden) {
        pauseOutsideView();
        return;
      }
      if (motionPreference.matches || connection?.saveData || userPaused || video.ended) return;
      // Native controls remain available if the browser declines autoplay.
      video.play().catch(() => {});
    };
  
    video.addEventListener("pause", () => {
      if (automaticPause) automaticPause = false;
      else if (!video.ended) userPaused = true;
    });
    video.addEventListener("play", () => { userPaused = false; });
  
    const observer = new IntersectionObserver(entries => {
      inView = entries[0].isIntersecting && entries[0].intersectionRatio >= 0.35;
      updatePlayback();
    }, { threshold: [0, 0.35] });
    observer.observe(video);
  
    document.addEventListener("visibilitychange", updatePlayback);
    motionPreference.addEventListener("change", () => {
      if (motionPreference.matches) pauseOutsideView();
      else updatePlayback();
    });
  })();
  