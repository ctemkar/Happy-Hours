<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection
$host = "smartshehar.com";
$username = "happyhours"; // Adjust based on your MySQL setup
$password = "abcd1245"; // Adjust based on your MySQL setup
$database = "happy_hours";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    error_log("Connection failed: " . $conn->connect_error);
    http_response_code(500);
    echo json_encode(["error" => "Database connection failed: " . $conn->connect_error]);
    exit;
} 

// Create database and table if not exists
$conn->query("CREATE DATABASE IF NOT EXISTS $database");
$conn->select_db($database);
$createTable = $conn->query("
    CREATE TABLE IF NOT EXISTS happyhours (
        happy_hours_id  VARCHAR(255) NOT NULL PRIMARY KEY,
        venueName VARCHAR(255) NOT NULL,
        address TEXT NOT NULL,
        times VARCHAR(100) NOT NULL,
        specials TEXT NOT NULL,
        latitude DOUBLE NOT NULL,
        longitude DOUBLE NOT NULL
    )
");
if (!$createTable) {
    error_log("Table creation failed: " . $conn->error);
    http_response_code(500);
    echo json_encode(["error" => "Table creation failed: " . $conn->error]);
    exit;
}

// Handle API requests
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['status'])) {
        // Debug endpoint to check server status
        echo json_encode(["status" => "Server is running", "database" => "Connected"]);
        exit;
    }
    $result = $conn->query("SELECT * FROM happyhours");
    if ($result === false) {
        error_log("Query failed: " . $conn->error);
        http_response_code(500);
        echo json_encode(["error" => "Query failed: " . $conn->error]);
        exit;
    }
    $happyHours = [];
    while ($row = $result->fetch_assoc()) {
        $happyHours[] = $row;
    }
    echo json_encode($happyHours);
} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    $venueName = $data['venueName'] ?? '';
    $address = $data['address'] ?? '';
    $times = $data['times'] ?? '';
    $specials = $data['specials'] ?? '';
    $latitude = $data['latitude'] ?? 0.0;
    $longitude = $data['longitude'] ?? 0.0;

    if (empty($venueName) || empty($address) || empty($times) || empty($specials)) {
        http_response_code(400);
        echo json_encode(["error" => "All fields are required"]);
        exit;
    }

    $stmt = $conn->prepare("INSERT INTO happyhours (happy_hours_id, venueName, address, times, specials, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        error_log("Prepare failed: " . $conn->error);
        http_response_code(500);
        echo json_encode(["error" => "Prepare failed: " . $conn->error]);
        exit;
    }
    $stmt->bind_param("sssssdd", UUID(), $venueName, $address, $times, $specials, $latitude, $longitude);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(["id" => $stmt->insert_id]);
    } else {
        error_log("Insert failed: " . $stmt->error);
        http_response_code(500);
        echo json_encode(["error" => "Insert failed: " . $stmt->error]);
    }
    $stmt->close();
} else {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
}

$conn->close();
?>