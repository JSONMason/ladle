package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	// 1) Read the DATABASE_URL from the environment
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL environment variable is required")
	}

	// 2) Create a connection pool
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("Unable to create connection pool: %v", err)
	}
	defer pool.Close()

	// 3) Verify connectivity with retries
	const maxAttempts = 5
	const retryDelay = 2 * time.Second

	var pingErr error
	for i := 1; i <= maxAttempts; i++ {
		pingErr = pool.Ping(ctx)
		if pingErr == nil {
			log.Printf("✅ Connected to Postgres (attempt %d)", i)
			break
		}
		log.Printf("⚠️ Ping attempt %d failed: %v (retrying in %s)", i, pingErr, retryDelay)
		time.Sleep(retryDelay)
	}
	if pingErr != nil {
		log.Fatalf("❌ Could not connect to Postgres after %d attempts: %v", maxAttempts, pingErr)
	}

	// 4) Set up Gin router
	r := gin.Default()

	// 5) Health-check endpoint
	r.GET("/health", func(c *gin.Context) {
		// use the request’s context so cancellations/timeouts propagate
		if err := pool.Ping(c.Request.Context()); err != nil {
			c.JSON(500, gin.H{"status": "db down", "error": err.Error()})
		} else {
			c.JSON(200, gin.H{"status": "ok"})
		}
	})

	r.GET("/", func(c *gin.Context) {
		c.String(200, "Hello, World!!")
	})

	// 6) Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("🚀 Server listening on :%s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}
