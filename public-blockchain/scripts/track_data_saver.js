module.exports = {
  contractAddressSaver: async function (key_name, value) {
    const fs = require("fs");
    // json data
    var jsonData = `{ "${key_name}" : "${value}" }`;
    // stringify JSON Object
    //var jsonContent = JSON.stringify(jsonData);
    fs.writeFileSync(
      `../json-log/${key_name}-deployedContractAddress.json`,
      jsonData,
      "utf8",
      function (err) {
        if (err) {
          console.log("An error occurred while writing JSON Object to File.");
          return console.log(err);
        }
        console.log("JSON file has been saved.");
      }
    );
  },
};
