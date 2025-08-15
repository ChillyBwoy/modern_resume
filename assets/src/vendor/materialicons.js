const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

/**
 * Material Design Icons
 *
 * https://pictogrammers.com/library/mdi/
 */
module.exports = plugin(({ matchComponents, theme }) => {
  const iconsDir = path.join(
    __dirname,
    "../../../deps/materialdesignicons/svg"
  );
  const values = {};

  fs.readdirSync(iconsDir).forEach((file) => {
    const name = path.basename(file, ".svg");
    values[name] = { name, fullPath: path.join(iconsDir, file) };
  });

  matchComponents(
    {
      mdi: ({ name, fullPath }) => {
        const content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "");

        return {
          [`--mdi-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--mdi-${name})`,
          mask: `var(--mdi-${name})`,
          "mask-repeat": "no-repeat",
          "background-color": "currentColor",
        };
      },
    },
    { values }
  );
});
