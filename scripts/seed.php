<?php

declare(strict_types=1);

$host = getenv('DB_HOST') ?: 'db';
$port = getenv('DB_PORT') ?: '5432';
$db   = getenv('DB_NAME') ?: 'beer_company';
$user = getenv('DB_USER') ?: 'app';
$pass = getenv('DB_PASSWORD') ?: 'secret';

$dsn = "pgsql:host=$host;port=$port;dbname=$db";

try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    echo "Connected to database.\n";

} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage() . "\n");
}

$url = "https://api.adscanner.tv/punkapi/v2/beers?per_page=80";

$json = file_get_contents($url);

if ($json === false) {
    die("Failed to fetch PunkAPI data.\n");
}

$beers = json_decode($json, true);

if (!is_array($beers)) {
    die("Invalid JSON received.\n");
}

echo "Fetched " . count($beers) . " beers.\n";

$sqlProducts = "INSERT INTO products (
        name,
        description,
        tagline,
        abv
    )
    VALUES ";

$len = count($beers) - 1;

foreach ($beers as $index => $beer) {
    $sqlProducts .= sprintf("('%s', '%s', '%s', %.1f)",
        str_replace("'", "''", $beer['name']),
        str_replace("'", "''", $beer['description']),
        str_replace("'", "''", $beer['tagline']),
        $beer['abv']
    );

    if ($index < $len) {
        $sqlProducts .= ',
        ';
    }
}

$stmt = $pdo->prepare($sqlProducts);
$stmt->execute();


$sqlProductPacks = "INSERT INTO product_packs (
        product_id,
        type,
        price_per_liter,
        volume
    )
    VALUES ";

$dbBeers = $pdo->query('SELECT * FROM products', PDO::FETCH_ASSOC)->fetchAll();

$beerLength = count($dbBeers) - 1;

foreach ($dbBeers as $index => $dbBeer) {
    $price = (float)rand(400, 1000) / 100;

    $sqlProductPacks .= sprintf("(%d, '%s', %.2f, %.2f), (%d, '%s', %.2f, %.2f), (%d, '%s', %.2f, %.2f)",
        $dbBeer['id'],
        'bottle',
        $price,
        0.5,
        $dbBeer['id'],
        'crate',
        $price - ($price * 0.05),
        10,
        $dbBeer['id'],
        'keg',
        $price - ($price * 0.1),
        30
    );

    if ($index < $beerLength) {
        $sqlProductPacks .= ',
        ';
    }
}


$stmt = $pdo->prepare($sqlProductPacks);
$stmt->execute();

file_put_contents(dirname(__FILE__) . '/generated_insert.sql',$sqlProducts . '

' . $sqlProductPacks);
