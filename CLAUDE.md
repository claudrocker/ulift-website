# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Sitio estático de **URBANLIFT** (gimnasio de fuerza urbana en Chile). Astro 6 + Tailwind 4, sin backend ni CMS. Contenido en español de Chile, precios en CLP. Node >= 22.12.

`AGENTS.md` complementa este archivo con convenciones de estilo, commits y PRs — respetarlas.

---

## Comandos

```bash
npm run dev       # dev server → http://localhost:4321
npm run build     # build de producción → dist/
npm run preview   # sirve el último build
```

No hay tests, linter ni `astro check` configurados (`@astrojs/check` no está instalado). **`npm run build` es la única validación automática.** Para cambios de UI hay que verificar manualmente en el navegador a ancho móvil y desktop: navegación, apertura/cierre de modales, links externos y carga de imágenes.

Despliegue: Dockerfile multi-stage (Node 24 build → Nginx sirve `dist/`), `docker-compose.yml` conecta a la red externa `dokploy-network`. Plataforma Dokploy.

---

## Arquitectura

### Layout es el único punto de entrada

`src/layouts/Layout.astro` (props: `title: string`) envuelve **todas** las páginas: importa `global.css`, monta `Navbar` (pasándole `Astro.url.pathname`) y `Footer`, y carga Space Grotesk + Manrope + Material Symbols desde Google Fonts.

**Trampa importante:** el `<head>` incluye un gate anti-FOUC — `body { visibility: hidden }` hasta que `document.fonts.ready` resuelva, con fallback de 2s por `setTimeout`. Se agregó para eliminar la deformación del texto al cargar las fuentes. Si algo aparece invisible en desarrollo, revisar ese gate antes de cualquier otra cosa. No romperlo al agregar scripts al `<head>`.

`<html class="dark">` y `color-scheme: dark` están presentes, pero **no se usa ni una sola variante `dark:` en el código** — el tema oscuro está hardcodeado en los tokens. La clase es decorativa; no asumir que existe un toggle claro/oscuro.

### Patrón de modales (lo más importante del repo)

Los modales son HTML estático oculto con `hidden`, activado por JS inline en la página que los usa. La mecánica es siempre la misma:

- El disparador lleva un `data-*` con el id del modal (`data-coach-id="thomas-cabezas"`, `data-plan-id="plan-mensual"`).
- El modal se renderiza con `id={`modal-${id}`}`.
- Abrir = quitar `hidden`, agregar `flex`, `document.body.style.overflow = 'hidden'`. Cerrar = lo inverso.
- Cierre por botón (`data-modal-close` / `data-plan-close`), por backdrop (`data-modal-backdrop` / `data-plan-backdrop`) y por tecla Escape.

Existen **dos implementaciones duplicadas** de esta lógica, cada una en un `<script>` al final de su página:

| | Modales de coaches | Modales de planes |
|---|---|---|
| Página | `src/pages/modalidades.astro` | `src/pages/index.astro` |
| Componente | `CoachModal.astro` (recibe todos los datos por props) | `PlanModal.astro` (solo shell + `<slot />`) |
| Atributos | `data-coach-id`, `data-modal-close`, `data-modal-backdrop` | `data-plan-id`, `data-plan-close`, `data-plan-backdrop` |
| Selector de cierre | `[id^="modal-"]` | `[id^="modal-plan-"]` |

Los prefijos de selector **colisionan**: `[id^="modal-"]` en modalidades matchea también cualquier `modal-plan-*`. Hoy no hay página que monte ambos tipos; si se mezclan, unificar la lógica en un módulo compartido antes que duplicarla una tercera vez.

`PlanModal` es solo el contenedor (backdrop + card responsive); el contenido de cada plan vive en `src/components/plans/*.astro` como fragmentos sin frontmatter, insertados por slot:

```astro
<PlanModal id="plan-mensual"><PlanMensual /></PlanModal>
```

Cada `plans/*.astro` incluye su propio botón `data-plan-close`. Agregar un plan = crear el fragmento, montar el `PlanModal` al final de `index.astro`, y agregar `data-plan-id` a la card correspondiente de la grilla de precios.

### Contenido: `src/data/` vs hardcodeado

Solo los coaches están extraídos a módulos tipados: `src/data/coaches/<slug>.ts` exporta `export const coach = { id, name, specialty, description, quote, photo, instagramUrl, whatsappUrl }`. El `id` debe coincidir con el `data-coach-id` de la card. `modalidades.astro` los importa, arma el array `coaches` y los mapea a `<CoachModal {...coach} />`.

Todo lo demás (horarios, promoción de socios fundadores, textos de planes, feed de comunidad, zonas del espacio) está hardcodeado en el markup. No hay Content Collections.

**Los precios están duplicados** entre las cards de la grilla en `index.astro` y los fragmentos en `components/plans/`. Al cambiar un precio hay que actualizar ambos lugares, y dentro del fragmento hay además tres cifras derivadas que deben cuadrar: el precio referencial por mes, el total y el "Ahorra $X". Ya hubo una divergencia por esto (trimestral con `$95.823` en el modal contra `$94.473` en la grilla).

### Rutas

`src/pages/` mapea directo a URL: `/`, `/modalidades`, `/nuestro-espacio`, `/comunidad`, `/calistenia`, `/conocenos`.

- `/calistenia` es una sub-marca distinta (**LIFTSW.ACADEMY**, academia de clases) con su propio hero y calendario; comparte el sistema de diseño pero no el naming de URBANLIFT.
- `/conocenos` es una **ruta huérfana**: existe y funciona, pero no está en `navLinks` del Navbar ni linkeada desde ninguna página.

`Navbar.astro` define `navLinks` en su frontmatter (única fuente de la navegación) y marca activo con `currentPath.startsWith(href)`. El mismo array alimenta dos vistas: los links horizontales `hidden min-[880px]:flex` y el drawer lateral móvil (`min-[880px]:hidden`) que se abre con el botón hamburguesa a la izquierda del logo. Agregar una ruta al menú = agregarla a `navLinks`, aparece en ambas.

**El navbar usa un breakpoint propio de 880px, no `md` (768px)**, porque entre esos dos anchos el logo y los 5 links ya no caben. Está como valor arbitrario de Tailwind (`min-[880px]:`) en tres clases y **duplicado en el `matchMedia('(min-width: 880px)')` del script** — si se cambia, hay que cambiar los cuatro. El resto del sitio sigue usando `md`.

El drawer **no usa el patrón `hidden`/`flex`** de los modales: queda siempre en el DOM para poder animar el `translate-x`, y cerrado se marca con el atributo `inert` (fuera de pantalla, sin foco ni clicks). Su `closeMenu()` sale temprano si ya estaba cerrado, para no resetear `document.body.style.overflow` que comparte con los modales. También cierra al pasar a desktop vía `matchMedia('(min-width: 768px)')`, si no el scroll quedaría bloqueado.

El botón "UNIRSE AHORA" está comentado en el markup.

En `Footer.astro` los links de Contacto son placeholders `href="#"` y el bloque "Explora" está comentado. El único link de WhatsApp real y funcional es el FAB flotante (`wa.me/56932818911`), el mismo número que usan los modales de coaches.

---

## Sistema de diseño

Tokens Material Design 3 en `src/styles/global.css` dentro de `@theme` (Tailwind 4: no hay `tailwind.config.js`; el plugin se registra en `astro.config.mjs` vía `@tailwindcss/vite`). Cada `--color-x` genera `bg-x`, `text-x`, `border-x`, etc.

Los tokens que más se usan y se confunden:

| Token | Valor | Uso |
|---|---|---|
| `surface` / `background` | `#131313` | fondo base |
| `surface-container-lowest` | `#0e0e0e` | secciones alternadas |
| `surface-container` / `-high` / `-highest` | `#201f1f` / `#2a2a2a` / `#353534` | cards y modales |
| `primary` | `#ffb688` | naranjo claro, texto de acento |
| `primary-container` | `#e07317` | naranjo medio, links activos, énfasis |
| `brand-orange` | `#CC6400` | naranjo de marca, promociones |
| `on-background` / `on-surface` | `#e5e2e1` | texto principal |
| `on-surface-variant` | `#ddc1b1` | texto secundario |
| `outline` / `outline-variant` | `#a58c7d` / `#564337` | bordes |

Antes de inventar un token, leer `global.css`: la paleta MD3 completa ya está declarada (`on-primary-container`, `primary-fixed`, `inverse-surface`, etc.).

**El `@theme` reescribe la escala de radios** de Tailwind: `--radius-lg: 0.25rem` (default 0.5rem) y `--radius-xl: 0.5rem` (default 0.75rem) — todo sale más anguloso que en un proyecto Tailwind normal, es intencional (estética industrial). `--radius-full` y `--radius-default` también están declarados pero son **inertes**: en Tailwind 4 `rounded-full` es un valor estático (`calc(infinity * 1px)`) y no lee la escala. O sea, `rounded-full` sí produce círculos.

Utilidades custom (`@layer utilities` en `global.css`): `.kinetic-gradient` (gradiente 45° `#CC6400 → #e07317`, el CTA estándar), `.brand-gradient` (135°, mismos colores), `.video-mask-bottom` (fade inferior en imágenes de hero), `.text-overlap` (text-shadow para texto sobre imágenes), `.glass-panel`, `.industrial-texture`.

Tipografía: `font-headline` = Space Grotesk (titulares, casi siempre `uppercase tracking-tighter`), `font-body` = Manrope. Íconos con `<span class="material-symbols-outlined">nombre_del_icono</span>`; el relleno se controla con `style="font-variation-settings:'FILL' 1"`.

---

## `docs/source/` — referencias de diseño

17 HTMLs pre-generados que son la **fuente de verdad de diseño y contenido**, no código de la aplicación. Cuando se pide una sección, página o modal nuevo, revisar primero si ya existe el HTML de referencia y portarlo al sistema de componentes:

- Páginas: `pagina-inicio.html`, `pagina-conocenos.html`, `pagina-modalidades.html`, `pagina-nuestro-espacio.html`
- Planes: `plan-mensual.html`, `plan-trimestral.html`, `plan-semestral.html`, `plan-anual-prepago.html`, `suscripcion-anual.html`, `plan-fundadores.html`
- Coaches: `p-<slug>.html` (Alfonso Moya, Allison Bassa, Fabián López, Marisa Trujillo, Thomas Cabezas)
- Flujo de clases: `codigo-calendario-clases-liftsw.html`, `exito-agendar-clase.html`

Hay referencias aún no implementadas (`plan-fundadores`, el flujo de agendamiento de clases) — sirven de guía cuando se pidan.

`README.md` es el template sin modificar de "Astro Starter Kit: Minimal"; no contiene información del proyecto.

---

## Pendientes conocidos

- Formularios sin conectar: el de prueba gratuita en `conocenos.astro` no tiene `action` ni handler.
- Botones de compra en los modales de planes sin integración de pago (Transbank/Stripe).
- SEO: `Layout.astro` tiene `<meta name="description" content="Astro description" />` (placeholder). Sin Open Graph ni schema markup.
- Salvo el logo del Navbar (`public/img/urbanlift-logo.png`), todas las imágenes son URLs de `lh3.googleusercontent.com` (Google Drive/AI Studio) — sin `astro:assets`, sin optimización, sin garantía de permanencia.
- Sin analítica ni CI/CD.
