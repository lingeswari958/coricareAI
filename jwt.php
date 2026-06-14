<?php


class JWTHelper {
    private static $secret_key = null;

    private static function getSecret() {
        if (self::$secret_key === null) {
            self::$secret_key = getenv('JWT_SECRET') ?: 'coricare_secure_farming_jwt_secret_key_2026';
        }
        return self::$secret_key;
    }


    private static function base64UrlEncode($data) {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }

    private static function base64UrlDecode($data) {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $padlen = 4 - $remainder;
            $data .= str_repeat('=', $padlen);
        }
        return base64_decode(str_replace(['-', '_'], ['+', '/'], $data));
    }

    public static function generate($payload, $expiry = 604800) {
        $header = json_encode([
            'typ' => 'JWT',
            'alg' => 'HS256'
        ]);

        $payload['iat'] = time();
        $payload['exp'] = time() + $expiry;
        $payload_json = json_encode($payload);

        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload_json);

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::getSecret(), true);
        $base64UrlSignature = self::base64UrlEncode($signature);

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

  
    public static function validate($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        list($base64UrlHeader, $base64UrlPayload, $base64UrlSignature) = $parts;

        // Verify Signature
        $signature = self::base64UrlDecode($base64UrlSignature);
        $expectedSignature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::getSecret(), true);

        if (!hash_equals($signature, $expectedSignature)) {
            return false;
        }

       
        $payload = json_decode(self::base64UrlDecode($base64UrlPayload), true);
        if (!$payload) {
            return false;
        }

        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false; // Token has expired
        }

        return $payload;
    }

    public static function getBearerToken() {
        $headers = null;
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } else if (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
            if (isset($requestHeaders['Authorization'])) {
                $headers = trim($requestHeaders['Authorization']);
            }
        }
        
        if (!empty($headers)) {
            if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
                return $matches[1];
            }
        }
        return null;
    }


    public static function authenticate() {
        $token = self::getBearerToken();
        if (!$token) {
            http_response_code(401);
            echo json_encode([
                "status" => "error",
                "message" => "Authorization Bearer token is missing."
            ]);
            exit();
        }

        $decoded = self::validate($token);
        if (!$decoded) {
            http_response_code(401);
            echo json_encode([
                "status" => "error",
                "message" => "Session expired or invalid token. Please log in again."
            ]);
            exit();
        }

        return $decoded;
    }
}
?>
