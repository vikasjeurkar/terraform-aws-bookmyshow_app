```bash
#!/bin/bash

# Update packages
dnf update -y

# Install Nginx
dnf install -y nginx

# Enable Nginx at boot
systemctl enable nginx

# Start Nginx
systemctl start nginx

# Remove default Nginx page
rm -f /usr/share/nginx/html/index.html

# Create MovieBook page
cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>MovieBook - Movie Ticket Booking</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: #f5f5f5;
            color: #222;
        }

        /* NAVBAR */

        .navbar {
            background: #e91e63;
            color: white;

            padding: 16px 7%;

            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
        }

        .location {
            font-size: 15px;
        }

        .login {
            background: white;
            color: #e91e63;

            border: none;
            border-radius: 5px;

            padding: 9px 20px;

            font-weight: bold;
            cursor: pointer;
        }

        /* HERO */

        .hero {
            min-height: 350px;

            display: flex;
            align-items: center;
            justify-content: center;

            text-align: center;

            color: white;

            background:
                linear-gradient(
                    rgba(0,0,0,0.65),
                    rgba(0,0,0,0.65)
                ),
                url("https://images.unsplash.com/photo-1489599849927-2ee91cede3ba")
                center/cover;
        }

        .hero h1 {
            font-size: 45px;
            margin-bottom: 15px;
        }

        .hero p {
            font-size: 20px;
        }

        /* MOVIES */

        .container {
            width: 86%;
            margin: 40px auto;
        }

        .section-title {
            font-size: 26px;
            margin-bottom: 25px;
        }

        .movies {
            display: grid;

            grid-template-columns:
                repeat(auto-fit, minmax(220px, 1fr));

            gap: 25px;
        }

        .movie-card {
            background: white;

            border-radius: 10px;

            overflow: hidden;

            box-shadow:
                0 3px 12px rgba(0,0,0,0.15);

            transition: 0.3s;
        }

        .movie-card:hover {
            transform: translateY(-5px);
        }

        .movie-card img {
            width: 100%;
            height: 280px;

            object-fit: cover;
        }

        .movie-info {
            padding: 16px;
        }

        .movie-info h3 {
            margin-bottom: 8px;
        }

        .movie-info p {
            color: #777;
            margin-bottom: 15px;
        }

        .book-btn {
            width: 100%;

            padding: 11px;

            border: none;

            border-radius: 5px;

            background: #e91e63;
            color: white;

            font-size: 15px;
            font-weight: bold;

            cursor: pointer;
        }

        .book-btn:hover {
            background: #c2185b;
        }

        /* FOOTER */

        .footer {
            background: #222;

            color: #aaa;

            text-align: center;

            padding: 25px;

            margin-top: 50px;
        }

        .server {
            margin-top: 10px;

            color: #e91e63;

            font-weight: bold;
        }

        /* MOBILE */

        @media (max-width: 600px) {

            .navbar {
                padding: 15px 4%;
            }

            .hero h1 {
                font-size: 30px;
            }

            .hero p {
                font-size: 16px;
            }

            .container {
                width: 92%;
            }
        }

    </style>

</head>

<body>

    <!-- NAVBAR -->

    <nav class="navbar">

        <div class="logo">
            MovieBook
        </div>

        <div class="location">
            📍 Pune
        </div>

        <button class="login">
            Login
        </button>

    </nav>


    <!-- HERO -->

    <section class="hero">

        <div>

            <h1>
                Movies. Events. Entertainment.
            </h1>

            <p>
                Book your favourite movies and enjoy the show!
            </p>

        </div>

    </section>


    <!-- MOVIES -->

    <main class="container">

        <h2 class="section-title">
            Recommended Movies
        </h2>


        <div class="movies">


            <!-- MOVIE 1 -->

            <div class="movie-card">

                <img
                    src="https://images.unsplash.com/photo-1489599849927-2ee91cede3ba"
                    alt="Movie">

                <div class="movie-info">

                    <h3>
                        Avengers: The Return
                    </h3>

                    <p>
                        Action • Adventure • 2h 30m
                    </p>

                    <button class="book-btn">
                        Book Tickets
                    </button>

                </div>

            </div>


            <!-- MOVIE 2 -->

            <div class="movie-card">

                <img
                    src="https://images.unsplash.com/photo-1485846234645-a62644f84728"
                    alt="Movie">

                <div class="movie-info">

                    <h3>
                        The Last Journey
                    </h3>

                    <p>
                        Drama • Adventure • 2h 15m
                    </p>

                    <button class="book-btn">
                        Book Tickets
                    </button>

                </div>

            </div>


            <!-- MOVIE 3 -->

            <div class="movie-card">

                <img
                    src="https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c"
                    alt="Movie">

                <div class="movie-info">

                    <h3>
                        Galaxy Wars
                    </h3>

                    <p>
                        Sci-Fi • Action • 2h 45m
                    </p>

                    <button class="book-btn">
                        Book Tickets
                    </button>

                </div>

            </div>


            <!-- MOVIE 4 -->

            <div class="movie-card">

                <img
                    src="https://images.unsplash.com/photo-1518929458119-e5bf444c30f4"
                    alt="Movie">

                <div class="movie-info">

                    <h3>
                        Love Story
                    </h3>

                    <p>
                        Romance • Drama • 2h 05m
                    </p>

                    <button class="book-btn">
                        Book Tickets
                    </button>

                </div>

            </div>


        </div>

    </main>


    <!-- FOOTER -->

    <footer class="footer">

        <p>
            © 2026 MovieBook
        </p>

        <p class="server">
            AWS EC2 • Nginx Web Server 2
        </p>

    </footer>


</body>

</html>
EOF

# Set permissions
chmod -R 755 /usr/share/nginx/html

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx

