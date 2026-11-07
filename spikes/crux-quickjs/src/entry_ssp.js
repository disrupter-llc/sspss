import './src_ssp/index.js';
const golden = globalThis.golden;
let cached = null;
function flat(m, o) { for (const v of m.values) { if (v && v.values) flat(v, o); else { const p = { s: v.step, t: v.timeScale }; if (v.tag) p.g = v.tag; if (v.diad) p.d = v.diad; o.push(p); } } return o; }
// Edit path: parse + interp. Returns JSON or throws (syntax error message).
globalThis.cruxEdit = function (src, seed) {
  const ast = golden.parse(src); cached = ast;
  return globalThis.cruxReseed(seed);
};
// Reseed path: re-interp the cached AST only.
globalThis.cruxReseed = function (seed) {
  golden.CRUX_SEED = seed; golden._interpGen++;
  const v = cached.interp();
  return JSON.stringify(v.sections.map(m => flat(m, [])));
};
