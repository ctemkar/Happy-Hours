<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Database connection
$host = "mysql2-p2.ezhostingserver.com";
$username = "sanjay"; // Adjust based on your MySQL setup
$password = "BU@R9gr2971{"; // Adjust based on your MySQL setup
$database = "interview_helper";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    error_log("Connection failed: " . $conn->connect_error);
    http_response_code(500);
    echo json_encode(["error" => "Database connection failed: " . $conn->connect_error]);
    exit;
} 

// Handle API requests
//$method = $_SERVER['REQUEST_METHOD'];

    $result = $conn->query("SELECT * FROM happy_hours_bangkok");
    if ($result === false) {
        error_log("Query failed: " . $conn->error);
        http_response_code(500);
        echo json_encode(["error" => "Query failed: " . $conn->error]);
        exit;
    }
    $happyHours = [];
    while ($row = $result->fetch_assoc()) {
        //$image = $row['image'] ?? '';
        //$logo = $row['logo'] ?? '';
        //$row['image_link'] = !empty($image) ? $image : (!empty($logo) ? $logo : '');
        $row['latitude'] = (float)$row['latitude'];
        $row['longitude'] = (float)$row['longitude'];
        $happyHours[] = $row;
    }
    echo json_encode($happyHours);

$conn->close();
?>