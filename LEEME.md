# Cuentas de la misión

App para llevar las entradas y salidas de plata de la misión, con la foto de cada factura.

Cada movimiento recibe un número consecutivo automático (N° 0001, N° 0002...). La foto de la factura se guarda con ese mismo número, y queda amarrada al valor que tú escribes. Al descargar el .zip cada foto lleva el número, la fecha y el valor marcados abajo, y el archivo se llama igual que la fila del Excel.

## Archivos

- **index.html** es la app
- **config.js** es donde pegas los datos de tu Supabase
- **schema.sql** crea la base de datos (solo se usa una vez en Supabase, no hace falta subirlo a GitHub)

## Paso 1. Crear la base de datos en Supabase

1. Entra a supabase.com y crea una cuenta gratis (puedes entrar con GitHub).
2. Toca **New project**. Ponle nombre, por ejemplo cuentas-mision. Inventa una contraseña para la base de datos y guárdala. En región escoge **South America (São Paulo)**, que es la más cerca de Colombia.
3. Espera uno o dos minutos a que el proyecto quede listo.
4. En el menú de la izquierda entra a **SQL Editor** y toca **New query**.
5. Abre schema.sql, copia todo, pégalo ahí y toca **Run**. Debe decir Success.

## Paso 2. Conectar la app con Supabase

1. En Supabase toca el botón **Connect** de arriba, o entra a **Project Settings** y luego **API Keys**.
2. Copia la **Project URL** (algo como https://abcd.supabase.co).
3. Copia la llave **anon public** o **publishable**. Nunca uses la llave service_role o secret.
4. Abre config.js y reemplaza TU_PROYECTO y TU_LLAVE con lo que copiaste.

La llave anon es pública a propósito. Lo que protege los datos son las reglas del schema.sql. Alguien que no esté aprobado no ve nada.

## Paso 3. Publicar en GitHub Pages

1. En github.com crea un repositorio nuevo, **público**, llamado por ejemplo cuentas-mision.
2. Toca **Add file** y luego **Upload files**. Sube index.html y config.js. Toca **Commit changes**.
3. Entra a **Settings** del repositorio y luego **Pages**.
4. En **Source** escoge **Deploy from a branch**, rama **main**, carpeta **/ (root)**. Guarda.
5. Espera un minuto. Tu link queda así: https://TU_USUARIO.github.io/cuentas-mision/

## Paso 4. Decirle a Supabase cuál es tu link

1. En Supabase entra a **Authentication** y luego **URL Configuration**.
2. En **Site URL** pega tu link de GitHub Pages.
3. En **Redirect URLs** agrega el mismo link. Guarda.

Así los correos de confirmar cuenta y de cambiar contraseña llevan a tu app.

## Paso 5. Crear tu cuenta y la de tu equipo

1. Abre tu link y toca **Crear cuenta**. Confirma con el correo que te llega.
2. La primera cuenta que se crea queda como **Admin** automáticamente. Por eso créala tú primero.
3. Pásale el link a tu equipo. Cada uno crea su cuenta y queda **Pendiente**.
4. En la pestaña **Equipo** les das permiso:
   - **Lector** solo ve cuánto hay y en qué se gastó
   - **Editor** además registra gastos y sube facturas
   - **Admin** además aprueba gente y cambia el nombre y presupuesto

## Para tenerla como app en el celular

- iPhone en Safari: botón de compartir y luego **Agregar a pantalla de inicio**
- Android en Chrome: menú de tres puntos y luego **Agregar a la pantalla principal**

## Si algo falla

- **No llega el correo de confirmación.** El plan gratis de Supabase manda pocos correos por hora. Puedes apagar la confirmación en Authentication, luego Sign In / Providers, luego Email, y desactivar **Confirm email**. Así la gente entra de una vez al crear la cuenta.
- **La app dice Falta un paso.** El config.js todavía tiene TU_PROYECTO. Revisa el paso 2.
- **Dice que no se pudo conectar con la base de datos.** Seguramente el schema.sql no corrió completo. Revisa el paso 1.
- **Cambié config.js y no se ve el cambio.** GitHub Pages tarda uno o dos minutos. Recarga la página.

## Sobre los números

- Los números nunca se repiten. Si borras el N° 0005, el siguiente sigue siendo el 0006. Así nadie puede reemplazar una factura borrando y creando otra con el mismo número.
- Puedes buscar un movimiento escribiendo su número en el buscador, por ejemplo 7 o 0007.
- En Resumen sale la lista de números que todavía no tienen factura.
