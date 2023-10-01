<?php

$sleepInSecond = 5;
$apiToken = "6369084280:AAFxZhzm4CrUznvj7ZAENCznn3AR-JKqg7M";
$chat_id = '@test_message123';
$servername = "localhost";
$username = "root";
$password = "Admin@123";
$dbname = "VoiceRecord";
$conn = mysqli_connect($servername, $username, $password, $dbname);

if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}
echo "Connected successfully\n";

while (true) {
	sleep($sleepInSecond);
	$sql = "SELECT * FROM `log` LIMIT 10";
	$result = $conn->query($sql);
	if ($result->num_rows > 0) {
		while($row_log = $result->fetch_assoc()) {
			$output = "";
			$output_log = "";
			$output_ReportCDRActive = "";
			$output_log .= 
			"TimeCheck = " . $row_log["TimeAction"] . "\n"
			. $row_log["Name"] . " " . $row_log["ContractCode"] . "\n"
			. "New Number Added: ". $row_log["Number"] . "\n";

			$sql2 = "SELECT Number FROM `ReportCDRActive` WHERE Name = '". $row_log['Name'] . "' LIMIT 10";
			$result2 = $conn->query($sql2);

			while ($row2 = $result2->fetch_assoc()) {
				$output_ReportCDRActive .= $row2['Number'] . "\n";
			}
			
			$output .= $output_log . $output_ReportCDRActive;

			$data = [
				'chat_id' => $chat_id, 
				'text' => $output,
			];
			$response = 
			file_get_contents("https://api.telegram.org/bot".$apiToken."/sendMessage?" .
											http_build_query($data) );
			$responseJson = json_decode($response);

			if($responseJson->ok == true) {
				$sqlDeleteLog = "DELETE FROM `log` WHERE ID = ". $row_log['ID'];
				echo "Send message, name company: ". $row_log['Name']. "\n";
				$conn->query($sqlDeleteLog);
			}
		}
	}
}
?>
