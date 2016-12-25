<?php

  // Put your device token here (without spaces):
  // $deviceToken = '1e286e3dba53b6a66efd846b74c94eea02050fd2fbf616001511864f1d02b71a';
  $deviceToken = '1d57fe1d33f544aa1fde3a3e4cdad46a4537e92f9fc81bd687a75d36b7ad4c3d';

  // Put your private key's passphrase here:
  $passphrase = 'PersonalAssistant';

  $message = $argv[1];
  $url = $argv[2];

  if (!$message || !$url)
  exit('Example Usage: $php newspush.php \'Breaking News!\' \'https://raywenderlich.com\'' . "\n");

  ////////////////////////////////////////////////////////////////////////////////

  // $https['ssl']['verify_peer'] = FALSE;
  // $https['ssl']['verify_peer_name'] = FALSE;

  // $contextOptions = array(
  //     'ssl' => array(
  //         'verify_peer' => true, // You could skip all of the trouble by changing this to false, but it's WAY uncool for security reasons.
  //         // 'cafile' => '/etc/ssl/cert.pem',
  //         'CN_match' => 'ck.pem', // Change this to your certificates Common Name (or just comment this line out if not needed)
  //         'ciphers' => 'HIGH:!SSLv2:!SSLv3',
  //         'disable_compression' => true,
  //     )
  // );
  // $context = stream_context_create($contextOptions);



  $context = stream_context_create();
  stream_context_set_option($context, 'ssl', 'local_cert', 'PersonalAssistant.pem');
  stream_context_set_option($context, 'ssl', 'passphrase', $passphrase);
  // stream_context_set_option($context, 'ssl', 'verify_peer', true);
  // stream_context_set_option($context, 'ssl', 'cafile', 'cacert.pem');
  stream_context_set_option($context, 'ssl', 'allow_self_signed', true);
  stream_context_set_option($context, 'ssl', 'verify_peer', false);

  // Open a connection to the APNS server
  $fp = stream_socket_client(
                             'ssl://gateway.sandbox.push.apple.com:2195', $err,
                             $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $context);

  if (!$fp)
  exit("Failed to connect: $err $errstr" . PHP_EOL);

  echo 'Connected to APNS' . PHP_EOL;

  // Create the payload body
  //$body['aps'] = array(
  //  'alert' => $message,
  //  'sound' => 'default',
  //  'link_url' => $url,
  //  );

  // $body['aps'] = array(
  //  'alert' => $message,
  //  'sound' => 'default',
  //  'link_url' => $url,
  //  'category' => 'NEWS_CATEGORY',
  //  );

  // $body['aps'] = array(
  //  'alert' => $message,
  //  'sound' => 'default',
  //  'link_url' => $url,
  //  'category' => 'message',
  //  'mutable-content' => 1
  //  );

  $body = array(
                'aps' => array(
                               'alert' => $message,
                               'sound' => 'default',
                               'link_url' => $url,
                               'category' => 'message',
                               //  'category' => 'eventInvitation',
                               //  'category' => 'eventUpdate',
                               'mutable-content' => 1,
                               ),
                'encrypted-content' => '#myencryptedcontent',
                'picture' => 'queen.png',
                );
  
  // Encode the payload as JSON
  $payload = json_encode($body);
  
  // Build the binary notification
  $msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
  
  // Send it to the server
  $result = fwrite($fp, $msg, strlen($msg));
  
  if (!$result)
  echo 'Message not delivered' . PHP_EOL;
  else
  echo 'Message successfully delivered' . PHP_EOL;
  
  // Close the connection to the server
  fclose($fp);
