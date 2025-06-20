# 🛍️ AI-Powered Product Search

A Ruby console application that uses OpenAI's function calling to search through a product database using natural language queries.

## ✨ Features

- **Natural Language Search**: Ask for products using everyday language
- **AI-Powered Filtering**: OpenAI intelligently filters products based on your criteria
- **Smart Product Matching**: Understands context, synonyms, and complex requirements
- **Interactive Console Interface**: Easy-to-use command-line interface
- **Comprehensive Product Database**: Electronics, Fitness, Kitchen, Books, and Clothing items

## 🚀 Quick Start

### Prerequisites

- Ruby 2.7 or higher
- Bundler gem
- OpenAI API key

### Installation

1. **Clone or navigate to the project directory:**
   ```bash
   cd task_10
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up your OpenAI API key:**
   Create a `.env` file in the project root:
   ```bash
   echo "OPENAI_API_KEY=your_openai_api_key_here" > .env
   ```
   Replace `your_openai_api_key_here` with your actual OpenAI API key.

4. **Run the application:**
   ```bash
   ruby product_search.rb
   ```

## 🎯 Usage Examples

Once the application starts, you can enter natural language queries like:

### Sample Queries:
- `"I need a smartphone under $800 with good rating"`
- `"Show me fitness equipment under $100"`
- `"Find books for programmers"`
- `"I want electronics with rating above 4.5"`
- `"Looking for kitchen appliances that are in stock"`
- `"Need wireless headphones with great reviews"`

### Sample Output:
```
🛍️  AI-Powered Product Search
========================================
Enter your search query (e.g., 'I need a smartphone under $800 with good rating'):
Type 'exit' to quit

> I need a book for programmers

🤖 Processing your request with AI...

Search criteria: Programming books for developers
==================================================
Filtered Products:
1. Programming Guide - $49.99, Rating: 4.7, In Stock

Total: 1 product(s) found
```

## 📁 Project Structure

```
task_10/
├── lib/
│   ├── database_connection.rb    # JSON database interface
│   ├── openai_client.rb         # OpenAI API client
│   └── product_search_service.rb # Main search logic
├── dataset.json                 # Product database
├── product_search.rb           # Main application entry point
├── Gemfile                     # Ruby dependencies
├── .env                       # Environment variables (create this)
├── .gitignore                 # Git ignore file
└── README.md                  # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
OPENAI_API_KEY=your_openai_api_key_here
DEBUG=false  # Set to 'true' for debugging API responses
```

### Model Configuration

The application uses `gpt-4.1-mini` by default. You can modify this in `lib/openai_client.rb` if needed.

## 🛠️ Development

### Adding New Products

Edit `dataset.json` to add new products. Each product should have:
- `name`: Product name
- `category`: Category (Electronics, Fitness, Kitchen, Books, Clothing)
- `price`: Price as a number
- `rating`: Rating from 0-5
- `in_stock`: Boolean availability status

### Extending Functionality

The application is modular and easy to extend:

- **DatabaseConnection**: Add new query methods
- **OpenAIClient**: Add new API endpoints
- **ProductSearchService**: Modify search logic or add new features

## 🐛 Troubleshooting

### Common Issues:

1. **"OPENAI_API_KEY not found" error:**
   - Ensure your `.env` file exists and contains a valid API key
   - Check that the API key starts with `sk-`

2. **"Invalid model" error:**
   - The model name might be incorrect
   - Try changing to `gpt-4o-mini` or `gpt-3.5-turbo` in `lib/openai_client.rb`

3. **Network/API errors:**
   - Check your internet connection
   - Verify your OpenAI API key has sufficient credits
   - Enable debug mode: `DEBUG=true ruby product_search.rb`

4. **No function calling:**
   - The AI might respond with text instead of calling the function
   - Try rephrasing your query to be more specific about products

### Debug Mode

Run with debug mode to see detailed API responses:
```bash
DEBUG=true ruby product_search.rb
```

## 📊 Supported Product Categories

- **Electronics**: Smartphones, laptops, headphones, etc.
- **Fitness**: Exercise equipment, yoga mats, weights, etc.
- **Kitchen**: Appliances, cookware, small appliances, etc.
- **Books**: Programming guides, novels, cookbooks, etc.
- **Clothing**: Apparel, shoes, accessories, etc.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is for educational and demonstration purposes.

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Enable debug mode to see detailed error messages
3. Verify your OpenAI API key and credits
4. Check that all dependencies are installed correctly

---

**Happy searching! 🔍✨** 