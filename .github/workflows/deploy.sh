name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main # Or your default branch name

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5

      - name: Build Web
        # The trailing slash in base-href is critical!
        run: flutter build web --release --base-href "${{ steps.pages.outputs.base_path }}/"

      - name: Upload Artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4