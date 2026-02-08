document.addEventListener("DOMContentLoaded", () => {
  const sort = new URLSearchParams(window.location.search).get("sort");
  if (sort !== "name" && sort !== "updated") return;

  const activeLink = document.querySelector(`.projects-sort a[href$="sort=${sort}"]`);
  if (activeLink) {
    activeLink.classList.add("is-active");
    activeLink.setAttribute("aria-current", "true");
  }

  const cards = document.querySelector(".cards");
  if (!cards) return;

  const items = Array.from(cards.children);
  items.sort((a, b) => {
    if (sort === "name") {
      return (a.dataset.projectTitle || "").localeCompare(b.dataset.projectTitle || "");
    }

    const aDate = Date.parse(a.dataset.projectUpdated || "");
    const bDate = Date.parse(b.dataset.projectUpdated || "");

    if (Number.isNaN(aDate) && Number.isNaN(bDate)) {
      return (a.dataset.projectTitle || "").localeCompare(b.dataset.projectTitle || "");
    }
    if (Number.isNaN(aDate)) return 1;
    if (Number.isNaN(bDate)) return -1;
    return bDate - aDate;
  });

  items.forEach((item) => cards.appendChild(item));
});
