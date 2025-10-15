# 1️⃣ Hafif bir Node base image
FROM node:20-alpine

# 2️⃣ Çalışma dizini oluştur
WORKDIR /app

# 3️⃣ Package dosyalarını kopyala
COPY package*.json ./

# 4️⃣ Production bağımlılıklarını yükle
RUN npm install --production

# 5️⃣ Kodları kopyala
COPY . .

# 6️⃣ 4000 portunu expose et
EXPOSE 4000

# 7️⃣ Uygulamayı başlat
CMD ["npm", "start"]
