<?php
// defind variable to connect and token
$sleepInSecond = 1;
$apiToken = "your_api_token";
$chat_id = '@your_channel_id';
$servername = "localhost";
$username = "root";
$password = "your_password";
$dbname = "VoiceRecord";
$conn = mysqli_connect($servername, $username, $password, $dbname);

if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}
echo "Connected successfully\n";

while (true) {
	sleep($sleepInSecond);
	$sql = "SELECT * FROM `log_active` LIMIT 10";
	$result = $conn->query($sql);   // connect db and run sql query
	if ($result->num_rows > 0) { // if result return > 0
		while($row_log = $result->fetch_assoc()) { // after fetch association, it's return to array and assign to row_log
			$output = ""; // reset $output
			$output_log = ""; // reset $output_log
			$output_ReportCDRActive = ""; // reset $output_ReportCDRActive
			$output_log .= //format output with concat array
			"Số khoá mở hướng Viettel" . "\n"
			."TimeCheck = " . $row_log["TimeAction"] . "\n"
			. $row_log["Name"] . " " . $row_log["ContractCode"] . "\n"
			. "New Number Added: ". $row_log["Number"] . "\n";

			$sql2 = "SELECT Number FROM `ReportCDRActive` WHERE Name = '". $row_log['Name'] . "' LIMIT 10";
			$result2 = $conn->query($sql2); // connect db and run sql query sql2

			while ($row2 = $result2->fetch_assoc()) { // at this time, after fetch association, it's return to array and assign to row2.
				$output_ReportCDRActive .= $row2['Number'] . "\n"; // Assign all number after query $sql2 and concat
			}
			
			$output .= $output_log . $output_ReportCDRActive; // concat 2 output

			$data = [
				'chat_id' => $chat_id, 
				'text' => $output,
			]; // define body api
			$response = 
			file_get_contents("https://api.telegram.org/bot".$apiToken."/sendMessage?" .
											http_build_query($data) ); // define API 
			$responseJson = json_decode($response); // decode response to JSON

			if($responseJson->ok == true) { // Access in JSON and get Respon, if respon return ok then run block code below
				$sqlDeleteLog = "DELETE FROM `log_active` WHERE ID = ". $row_log['ID']; //Defind query SQL to delete log table with ID 
				echo "Send message, name company: ". $row_log['Name']. "\n";
				$conn->query($sqlDeleteLog); // execute query SQL
			}
		}
	}
}
?>
