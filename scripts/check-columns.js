const { BigQuery } = require("@google-cloud/bigquery");

async function main() {
  const client = new BigQuery({
    projectId: "bigquery-tutorial-480009",
    keyFilename: ".secrets/bigquery-sa.json",
    location: "US",
  });

  const sql = `
    SELECT table_name, column_name, data_type
    FROM \`bigquery-tutorial-480009.A2.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = 'View_Fact_Urine'
    ORDER BY ordinal_position
  `;

  const [rows] = await client.query(sql);
  console.log("Columns in View_Fact_Urine:");
  for (const r of rows) {
    console.log(`  ${r.column_name} (${r.data_type})`);
  }
}

main().catch(console.error);
