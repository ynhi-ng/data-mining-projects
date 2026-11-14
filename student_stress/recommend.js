(function () {
  const data = window.RECOMMEND_DATA;
  const select = document.getElementById("profileSelect");
  const cohortLine = document.getElementById("cohortLine");
  const grid = document.getElementById("recGrid");
  const disclaimer = document.getElementById("disclaimer");

  disclaimer.textContent = data.disclaimer;

  data.profiles.forEach((p, i) => {
    const opt = document.createElement("option");
    opt.value = p.id;
    opt.textContent = p.label;
    if (i === 0) opt.selected = true;
    select.appendChild(opt);
  });

  function render(profileId) {
    const profile = data.profiles.find((p) => p.id === profileId) || data.profiles[0];
    cohortLine.textContent = `Based on ${profile.cohort_n} students with similar profile`;
    grid.innerHTML = profile.recommendations
      .map((r, idx) => {
        const liftLabel =
          r.lift >= 1.05
            ? `${r.lift}× more common than average`
            : r.lift <= 0.95
              ? `${r.lift}× vs survey average`
              : `About as common as average`;
        return `
        <article class="rec">
          <div class="rec__title">${idx + 1}. ${r.rank_title}</div>
          <div class="rec__stat"><strong>${r.pct}%</strong> of similar students report this</div>
          <div class="rec__stat">${liftLabel}</div>
          <div class="rec__stat">Based on ${r.n} students · ${r.mechanism}</div>
        </article>`;
      })
      .join("");
  }

  select.addEventListener("change", () => render(select.value));
  render(select.value);
})();
