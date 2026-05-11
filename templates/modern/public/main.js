export default {
  start: () => {
    // DocFX calls custom startup code before its own PDF branch completes.
    // Leave PDF renders untouched so Chromium only waits on DocFX's built-ins.
    if (navigator.userAgent.includes("docfx/pdf") || window.location.pathname.endsWith(".pdf")) {
      return;
    }

    // API reference pages contain many generated signature blocks. Keep the
    // framed treatment for authored article pages.
    if (document.body.dataset.yamlMime === "ManagedReference") {
      return;
    }

    const article = document.querySelector("article");
    if (!article) {
      return;
    }

    for (const pre of article.querySelectorAll("pre")) {
      // Keep Highlight.js colors consistent everywhere, including DocFX tab
      // groups whose structure we should not wrap.
      pre.dataset.bsTheme = "dark";

      if (pre.closest(".frame")) {
        continue;
      }

      // Match the main sixlabors.com code-frame markup after DocFX has emitted
      // Markdown output, without adding a custom build-time post-processor.
      const frame = document.createElement("div");
      frame.className = "frame";
      frame.dataset.bsTheme = "dark";
      pre.before(frame);
      frame.append(pre);
    }
  }
};
