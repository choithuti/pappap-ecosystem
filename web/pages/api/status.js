export default async function handler(req, res) {
  const response = await fetch("http://127.0.0.1:8080/api/status");
  const data = await response.json();
  res.status(200).json(data);
}