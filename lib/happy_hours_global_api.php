<?php
// happy_hours_api.php
error_reporting(E_ALL);
ini_set('display_errors', 1); // set to 1 for debugging on dev only
ini_set('log_errors', 1);


header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Increase execution time just in case
set_time_limit(60);

// ---- Config (move to outside webroot or a .env file in production) ----
$host     = "mysql2-p2.ezhostingserver.com";
$username = "sanjay";
$password = "BU@R9gr2971{";
$database = "interview_helper";

// Start timer
$startTime = microtime(true);

// Connect (persistent connection)
$conn = new mysqli('p:' . $host, $username, $password, $database);
if ($conn->connect_error) {
    //logMessage("DB Connection failed: " . $conn->connect_error);
    jsonResponse(null, false, "Database connection failed", null, 500);
}
// Get dropdown value
$city = isset($_GET['city']) ? trim($_GET['city']) : 'ALL';

// Prepare query
if (strtoupper($city) === 'ALL') {
    //$sql = "SELECT * FROM happy_hours_bangkok";
    $sql = "SELECT happy_hours_id, Name, Address, Google_Marker, image_link, Open_hours, Happy_hour_start, Happy_hour_end, Telephone, latitude, longitude FROM happy_hours_bangkok";
    $stmt = $conn->prepare($sql);
} else {
    $sql = "SELECT happy_hours_id, Name, Address, Google_Marker, image_link, Open_hours, Happy_hour_start, Happy_hour_end, Telephone, latitude, longitude FROM happy_hours_bangkok WHERE city = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $city);
}

// Execute and get results
$stmt->execute();
$result = $stmt->get_result();

// Fetch all rows
$data = [];
while ($row = $result->fetch_assoc()) {
    foreach ($row as $key => $value) {
        // Convert NULL or false to empty string
        if ($value === null || $value === false) {
            $row[$key] = "";
        }
        // Ensure UTF-8 encoding
        elseif (!mb_check_encoding($value, 'UTF-8')) {
            $row[$key] = mb_convert_encoding($value, 'UTF-8', 'ISO-8859-1');
        }
    }
    $data[] = $row;
}

echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

// Check for JSON encoding errors
if (json_last_error() !== JSON_ERROR_NONE) {
    error_log("JSON Error: " . json_last_error_msg());
}

$conn->close();
?>