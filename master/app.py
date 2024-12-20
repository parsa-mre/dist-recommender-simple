# master/app.py
import os
from flask import Flask, jsonify, request

app = Flask(__name__)

# CouchDB Connection
# COUCHDB_URL = os.environ.get("COUCHDB_URL", "http://localhost:5984")
# DB_NAME = os.environ.get("DB_NAME", "movie_similarities")
USE_DUMMY_DATA = os.environ.get("USE_DUMMY_DATA", "false").lower() == "true"

dummy_data = {
    "1": {
        "similar_movies": [
            {"movie_id": 2, "avg_score": 0.95},
            {"movie_id": 3, "avg_score": 0.90},
            {"movie_id": 4, "avg_score": 0.85},
        ]
    },
    "2": {
        "similar_movies": [
            {"movie_id": 1, "avg_score": 0.95},
            {"movie_id": 3, "avg_score": 0.80},
            {"movie_id": 4, "avg_score": 0.75},
        ]
    },
}


def get_db_connection():
    # if USE_DUMMY_DATA:
    return dummy_data
    # try:
    #     server = Server(COUCHDB_URL)
    #     db = server[DB_NAME]
    #     return db
    # except Exception as e:
    #     app.logger.error(f"Database connection error: {e}")
    #     return None


@app.route("/similar_movies/<int:movie_id>", methods=["GET"])
def get_similar_movies(movie_id):
    db = get_db_connection()
    if not db:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        # Assuming movie similarities are stored with movie_id as key
        doc = dummy_data.get(str(movie_id))

        if not doc:
            return jsonify({"error": "Movie not found"}), 404

        # Retrieve similar movies, sorted by similarity score
        similar_movies = sorted(
            doc.get("similar_movies", []), key=lambda x: x["avg_score"], reverse=True
        )

        # Optional: Limit to top 10 similar movies
        similar_movies = similar_movies[:10]

        return jsonify({"movie_id": movie_id, "similar_movies": similar_movies})

    except Exception as e:
        app.logger.error(f"Error retrieving similar movies: {e}")
        return jsonify({"error": "Internal server error"}), 500


@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
