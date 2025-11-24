export default async function handler(req, res) {
  const response = await fetch("http://127.0.0.1:8080/api/prompt", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(req.body)
  });
  const data = await response.json();
  res.status(200).json(data);
}