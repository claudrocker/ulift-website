# CLAUDE.md — URBANLIFT Website

## Resumen del Proyecto

Sitio web estático para **URBANLIFT**, un gimnasio de entrenamiento de fuerza urbana en Chile. Construido con **Astro 6.1.9** y **Tailwind CSS 4.x**, desplegado con Docker + Nginx en la plataforma Dokploy.

- **Idioma:** Español (Chile)
- **Moneda:** CLP (Pesos Chilenos)
- **Versión:** 0.0.1 (primera versión)
- **Node requerido:** >=22.12.0

---

## Comandos Esenciales

```bash
npm run dev       # Servidor de desarrollo → http://localhost:4321
npm run build     # Build de producción → /dist
npm run preview   # Preview del build
```

### Docker

```bash
docker build -t urbanlift-website .
docker-compose up -d
```

---

## Stack Tecnológico

| Aspecto | Tecnología |
|---------|-----------|
| Framework | Astro 6.1.9 |
| Estilos | Tailwind CSS 4.2.4 (via `@tailwindcss/vite`) |
| Tipado | TypeScript (modo estricto) |
| Íconos | Material Symbols Outlined (Google Fonts) |
| Fuentes | Space Grotesk (titulares), Manrope (cuerpo) |
| Sistema de color | Material Design 3 |
| Despliegue | Docker multi-stage (Node 24 build + Nginx serve) |
| Plataforma | Dokploy |
| Package manager | npm |

---

## Estructura del Proyecto

```
ulift-website/
├── src/
│   ├── pages/                    # Rutas (file-based routing de Astro)
│   │   ├── index.astro           # Inicio: hero, horarios, promo, planes y precios
│   │   ├── conocenos.astro       # Misión, visión, formulario de prueba gratis
│   │   ├── nuestro-espacio.astro # Tour del espacio (bento grid de zonas)
│   │   ├── modalidades.astro     # Categorías de entrenamiento y coaches
│   │   └── comunidad.astro       # Feed tipo reels, redes sociales
│   ├── components/
│   │   ├── Navbar.astro          # Navegación fija, recibe `currentPath`
│   │   └── Footer.astro          # Footer + botón flotante de WhatsApp
│   ├── layouts/
│   │   └── Layout.astro          # Layout master: recibe `title: string`
│   └── styles/
│       └── global.css            # @theme Tailwind, utilidades custom
├── public/
│   ├── favicon.svg
│   └── favicon.ico
├── docs/                         # HTMLs de referencia visual pre-generados
│   ├── home.html
│   ├── conocenos.html
│   ├── modalidades.html
│   ├── nuestro-espacio.html
│   └── comunidad.html
├── Dockerfile                    # Build multi-stage Node → Nginx
├── docker-compose.yml            # Integración con red dokploy-network
├── astro.config.mjs              # Config Astro + plugin Tailwind/Vite
└── tsconfig.json                 # Extiende astro/tsconfigs/strict
```

---

## Páginas y sus Contenidos

### `index.astro` — Inicio
- Hero a pantalla completa con imagen de fondo y CTAs
- Horarios: 3 columnas (Lun-Vie, Sáb-Dom, Festivos)
- Promo socios fundadores: 40% descuento, cupos limitados (87/100)
- Tabla de precios (5 columnas, 12 variaciones):
  - Mensual prepago: $34.990
  - Trimestral -10%: $94.473
  - Semestral -15% (POPULAR): $178.452
  - Anual -30%: $293.916
  - Anual suscripción (con crédito): $335.904
  - Pase diario: $5.000

### `conocenos.astro` — Conócenos
- Bento grid con misión, visión e imagen de fondo
- Formulario de prueba gratuita (nombre + email)

### `nuestro-espacio.astro` — Nuestro Espacio
- Bento grid de 12 columnas con 6 zonas del gimnasio:
  - Calistenia y Street Lifting (4 cols, 2 rows)
  - Powerlifting (8 cols, 1 row)
  - Máquinas (4 cols, 1 row)
  - Peso Libre (4 cols, 1 row)
  - Zona Descanso (7 cols)
  - Baños y Camarines (5 cols)
- Efecto hover: scale + opacidad

### `modalidades.astro` — Modalidades
- Grid 2x2 con 4 categorías:
  1. Clases Grupales de Calistenia (coaches: Thomas, Allison)
  2. Clases Semi-Personalizadas (1:1 o grupos ≤4)
  3. Asesorías Online (mundial, feedback semanal, garantía de resultados)
  4. Equipo Profesional (Allison, Thomas, Fabian — +10 años experiencia)

### `comunidad.astro` — Comunidad
- Feed tipo reels (3 columnas, ratio 9:16)
  - Perfiles: @marcos_lift, @karla_coach, @urbanlift_oficial
- Sidebar: WhatsApp e Instagram + campeonato próximo

---

## Componentes

### `Navbar.astro`
```typescript
interface Props { currentPath: string; }
```
- Fijo (top-0, z-50) con backdrop blur
- Solo visible en desktop
- Link activo con borde inferior
- CTA "UNIRSE AHORA"

### `Footer.astro`
- Grid de links (Contacto, Legal, Explora)
- WhatsApp FAB fijo en esquina inferior derecha
- Copyright: © 2024 URBANLIFT — Eusebio Lillo 525, Piso 3

### `Layout.astro`
```typescript
interface Props { title: string; }
```
- HTML `lang="es"` con `class="dark"`
- Importa `global.css`, Navbar y Footer
- Pasa `currentPath` al Navbar vía `Astro.url.pathname`

---

## Sistema de Diseño

### Paleta de Colores (Material Design 3)

```css
/* Fondos */
--color-surface:         #131313   /* fondo principal */
--color-surface-lowest:  #0e0e0e   /* más oscuro */
--color-surface-high:    #2a2a2a   /* más claro */

/* Primario (naranjo) */
--color-primary:         #ffb688   /* naranjo claro */
--color-primary-medium:  #e07317   /* naranjo medio */
--color-brand-orange:    #CC6400   /* naranjo marca */

/* Texto */
--color-on-background:   #e5e2e1
--color-on-surface:      #ddc1b1
```

### Tipografía

- **Titulares:** `Space Grotesk` (variable `--font-headline`)
- **Cuerpo:** `Manrope` (variable `--font-body` y `--font-label`)

### Utilidades Custom (global.css)

```css
.kinetic-gradient    /* Gradiente CTA: 45°, #ffb688 → #e07317 */
.brand-gradient      /* Gradiente marca: 135°, #CC6400 → #e07317 */
.video-mask-bottom   /* Máscara fade en parte inferior de imágenes */
.text-overlap        /* Drop shadow para texto sobre imágenes */
.industrial-texture  /* Textura de fondo (desde Google Drive) */
.glass-panel         /* Efecto vidrio esmerilado (rgba + backdrop-blur) */
```

---

## Convenciones de Código

- Todo el contenido está **hardcodeado** en los archivos `.astro` (sin CMS)
- Las imágenes se alojan en **Google Drive** (URLs públicas)
- No hay backend, formularios o APIs conectadas actualmente
- Sin Content Collections de Astro — contenido directo en páginas
- Modo oscuro permanente (`class="dark"` en html, sin toggle)
- TypeScript estricto en todos los componentes

---

## Despliegue

### Docker

```dockerfile
# Stage 1: Build
FROM node:24-alpine AS build
WORKDIR /app
RUN npm install && npm run build

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
```

### docker-compose

- Red externa: `dokploy-network`
- Container: `urbanlift-website`
- Restart: `always`
- Puerto: `80:80`

---

## Archivos de Referencia

La carpeta `/docs/` contiene HTMLs pre-generados de referencia visual para cada página. Usarlos como guía de diseño y contenido cuando se agreguen nuevas secciones.

---

## Estado Actual y Próximos Pasos

### Listo
- 5 páginas completas con contenido y estilos
- Sistema de diseño Material Design 3 implementado
- Navbar y Footer funcionales
- Docker listo para producción

### Pendiente
- Conectar formularios (prueba gratuita, inscripción)
- Integrar analíticas (Google Analytics o similar)
- SEO: meta tags, Open Graph, schema markup
- Optimización de imágenes (reemplazar Google Drive por assets locales o CDN)
- CI/CD pipeline (GitHub Actions)
- Variables de entorno para diferentes ambientes
- Blog o contenido dinámico (opcional)
- Integración de pagos (Transbank o Stripe)
