# Using indexed ANN search in SingleStore

This repository contains a collection of SQL scripts and Python notebooks designed for generating and handling large-scale vector data in SingleStore, and scraping and processing Wikipedia video game data. Below is an overview of each file and its purpose. 

Although you can run the code from your python CLI, we recommend using VSCode to make the process of defining your virtual environment and running your Jupyter notebooks easier. This repository requires Python 3.9 or greater.

## Contents

1. **appendix.sql**: This SQL script is dedicated to generating 160,000,000 mock vectors in a table in SingleStore. It includes the definition of helper functions for generating a random, normalized, 1536-dimensional vector, which corresponds to the dimensionality of OpenAI embeddings from `text-ada-002`. The script also contains the code for creating a table `vecs` and inserting the mock vectors into it. These are the mock vectors that we will use to simulate the expected 160,000,000 paragraphs in Wikipedia. Additionally, it outlines the process of loading Wikipedia video game paragraphs and embeddings from an open AWS S3 bucket into the same table.

2. **s2_openai_info.py**: A Python script containing configurations for connecting to a database and OpenAI services. It includes placeholders for an API key, embedding model, GPT model, database username, password, connection string, port, and database name.

3. **scraping_wikipedia.ipynb**: A Jupyter notebook for scraping Wikipedia video game data. This notebook focuses on fetching URLs from a specific Wikipedia page, filtering them, extracting text from each page, generating embeddings using OpenAI's service, and storing the results in a SingleStore database.

4. **video-game-emb.ipynb**: Another Jupyter notebook designed for searching and querying the SingleStore database. It uses the OpenAI API for embedding generation and the SQLAlchemy library for database interaction. The notebook provides functions for embedding text, searching the database for similar content, and generating responses using OpenAI's GPT model.

## Setup, Configuration, and Usage Instructions

Before using these scripts, ensure that you have the necessary environment set up:
- Set up a SingleStore database instance that you can connect to.
- Follow along with the database setup as in `appendix.sql`:
   - Define the helper functions.
   - Define the table `vecs` 
   - Run the loop to generate the 160M mock vectors.
   - Define and run the pipeline `wiki_pipeline` to import the 40K OpenAI vectors for the video game paragraphs.
   - Build the vector index `ivfpq_nlist`.
- Install Python and the required libraries from `requirements.txt` in your `venv`. 
   - (Choose the 'Python: Create virtual environment' command in VSCode https://code.visualstudio.com/docs/python/environments#_creating-environments)
- Obtain and set your OpenAI API key in `s2_openai_info.py`.
- Configure your database connection details (username, password, connection string, port, and database name) in `s2_openai_info.py`.
- Run through the Jupyter notebook!

## Note

- Ensure all the dependencies are installed before running the notebooks.
- Keep your API key and database credentials secure.
- Regularly update the scripts and notebooks for compatibility with the latest versions of the libraries and APIs.

## Contribution

Contributions to improve the scripts or extend the functionality are welcome. Please follow the standard pull request process to contribute to this repository.