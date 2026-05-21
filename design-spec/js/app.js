/* To add interaction to website*/

//reveal timing to cards
// marks curr page in nav bar
// scroll porgress meter
//fast directional page swipe

   const links = document.querySelectorAll(".nav-links a");
   const currentPage = window.location.pathname.split("/").pop() || "index.html";
   const motionAllowed = !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
   const pageOrder = [
     "index.html",
     "colours.html",
     "typography.html",
     "logo.html",
     "principles.html",
     "components.html",
     "spacing.html",
     "accessibility.html",
     "wireframes.html",
   ];
   
   links.forEach((link) => {
     if (link.getAttribute("href") === currentPage) {
       link.setAttribute("aria-current", "page");
     }
   });
   
   const meter = document.createElement("div");
   meter.className = "scroll-meter";
   meter.setAttribute("aria-hidden", "true");
   meter.innerHTML = "<span></span>";
   document.body.prepend(meter);
   
   const updateScrollMeter = () => {
     const scrollable = document.documentElement.scrollHeight - window.innerHeight;
     const progress = scrollable > 0 ? (window.scrollY / scrollable) * 100 : 0;
     document.documentElement.style.setProperty("--scroll-progress", `${progress}%`);
   };
   
   updateScrollMeter();
   window.addEventListener("scroll", updateScrollMeter, { passive: true });
   window.addEventListener("resize", updateScrollMeter);
   
   document.querySelectorAll(".reveal").forEach((item, index) => {
     item.style.animationDelay = `${Math.min(index * 70, 420)}ms`;
   });
   
   if (motionAllowed) {
     document.querySelectorAll('a[href$=".html"], a[href="#sections"]').forEach((link) => {
       const href = link.getAttribute("href");
       if (!href || href.startsWith("#")) return;
   
       link.addEventListener("click", (event) => {
         const target = new URL(href, window.location.href);
         if (target.origin !== window.location.origin && window.location.protocol !== "file:") return;
   
         event.preventDefault();
         const currentIndex = pageOrder.indexOf(currentPage);
         const targetIndex = pageOrder.indexOf(target.pathname.split("/").pop() || "index.html");
         const directionClass = targetIndex > currentIndex ? "page-exit-left" : "page-exit-right";
         document.body.classList.add(currentIndex === -1 || targetIndex === -1 ? "page-exit" : directionClass);
         window.setTimeout(() => {
           window.location.href = href;
         }, 105);
       });
     });
   }
   