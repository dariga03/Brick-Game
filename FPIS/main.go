package main

import (
	"net/http"
	"sort"
	"strings"
	"sync"

	"github.com/gin-gonic/gin"
)

type Player struct {
	Name  string `json:"name"`
	Score int    `json:"score"`
}

type User struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Token    string `json:"token"`
	Username string `json:"username"`
}

var (
	leaderboard = map[string]Player{
		"Alice":   {"Alice", 1500},
		"Bob":     {"Bob", 1200},
		"Charlie": {"Charlie", 900},
	}
	users = map[string]User{
		"alice@example.com": {
			Email:    "alice@example.com",
			Password: "password123",
			Token:    "token_alice",
			Username: "Alice",
		},
		"bob@example.com": {
			Email:    "bob@example.com",
			Password: "password123",
			Token:    "token_bob",
			Username: "Bob",
		},
		"charlie@example.com": {
			Email:    "charlie@example.com",
			Password: "password123",
			Token:    "token_charlie",
			Username: "Charlie",
		},
	}
	mu sync.Mutex
)

func register(c *gin.Context) {
	var newUser User
	if err := c.BindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	if newUser.Username == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username is required"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	if _, exists := users[newUser.Email]; exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User already exists"})
		return
	}

	newUser.Token = "token_" + strings.Split(newUser.Email, "@")[0]

	users[newUser.Email] = newUser
	leaderboard[newUser.Username] = Player{Name: newUser.Username, Score: 0}

	c.JSON(http.StatusCreated, gin.H{"message": "User registered successfully"})
}

func login(c *gin.Context) {
	var loginUser User
	if err := c.BindJSON(&loginUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	for _, u := range users {
		if u.Email == loginUser.Email && u.Password == loginUser.Password {
			c.JSON(http.StatusOK, gin.H{"token": u.Token})
			return
		}
	}

	c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
}

func authMiddleware(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "No token provided"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	for _, u := range users {
		if token == u.Token {
			c.Set("user", u.Email)
			c.Next()
			return
		}
	}

	c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
}

func getLeaderboard(c *gin.Context) {
	mu.Lock()
	defer mu.Unlock()

	sortedLeaderboard := make([]Player, 0, len(leaderboard))
	for _, player := range leaderboard {
		sortedLeaderboard = append(sortedLeaderboard, player)
	}

	sort.Slice(sortedLeaderboard, func(i, j int) bool {
		return sortedLeaderboard[i].Score > sortedLeaderboard[j].Score
	})

	c.JSON(http.StatusOK, gin.H{"leaderboard": sortedLeaderboard})
}

func getPlayer(c *gin.Context) {
	name := c.Param("name")

	mu.Lock()
	defer mu.Unlock()

	player, exists := leaderboard[name]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
		return
	}

	c.JSON(http.StatusOK, player)
}

func getPlayers(c *gin.Context) {
	mu.Lock()
	defer mu.Unlock()

	var playerNames []string
	for _, player := range leaderboard {
		playerNames = append(playerNames, player.Name)
	}

	c.JSON(http.StatusOK, gin.H{"players": playerNames})
}

func updatePlayer(c *gin.Context) {
	name := c.Param("name")
	var updatedData Player

	if err := c.BindJSON(&updatedData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format"})
		return
	}

	mu.Lock()
	defer mu.Unlock()

	player, exists := leaderboard[name]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
		return
	}

	player.Score = updatedData.Score
	leaderboard[name] = player
	c.JSON(http.StatusOK, gin.H{"message": "Score updated", "player": player})
}

func deletePlayer(c *gin.Context) {
	name := c.Param("name")

	mu.Lock()
	defer mu.Unlock()

	if _, exists := leaderboard[name]; !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Player not found"})
		return
	}

	delete(leaderboard, name)
	c.JSON(http.StatusOK, gin.H{"message": "Player deleted"})
}

func getGames(c *gin.Context) {
	games := []string{"Race", "Tetris", "Snake", "Arkanoid"}
	c.JSON(http.StatusOK, gin.H{"games": games})
}

func main() {
	r := gin.Default()

	r.POST("/register", register)
	r.POST("/login", login)

	r.GET("/games", getGames)
	r.GET("/leaderboards", getLeaderboard)
	r.GET("/player/:name", getPlayer)
	r.GET("/players", getPlayers)

	auth := r.Group("/")
	auth.Use(authMiddleware)
	auth.PUT("/player/:name", updatePlayer)
	auth.DELETE("/player/:name", deletePlayer)

	r.Run(":8080")
}
