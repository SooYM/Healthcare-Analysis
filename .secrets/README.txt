  Account:  service1@bigquery-tutorial-480009.iam.gserviceaccount.com

  1. Google Cloud Console → IAM & Admin → IAM → open that service account.
  2. Keys → Add key → Create new key → JSON (download once).
  3. Save the file as this exact path (same folder as this README):

       bigquery-sa.json

     Full path:

       …/healthcare-dashboard/.secrets/bigquery-sa.json

  4. Restart: npm run dev

Do not commit *.json — gitignored.
