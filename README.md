Comando para ejecutar Docker con PostgreSQL. Pasos para configurar DataGrip. Creación de la base de datos PostgreSQL desde DataGrip.
docker run --name postgres-db -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres CREATE DATABASE my_first_database WITH TEMPLATE template0;
Explicación de los parámetros:
--name postgres-db: Asigna el nombre postgres-db al contenedor para facilitar su administración. -e POSTGRES_PASSWORD=yourpassword: Define como variable de entorno la contraseña para el usuario administrador por defecto (postgres). -p 5432:5432: Expone y mapea el puerto local 5432 al puerto interno 5432 del contenedor. -d: Ejecuta el contenedor en segundo plano (detached mode).
postgres: Indica a Docker que descargue y utilice la imagen oficial más reciente de PostgreSQL.
Configurar la conexión en DataGrip Una vez que el contenedor esté en ejecución, configura la conexión siguiendo estos pasos:
Abre DataGrip.

Dirígete a la ventana del Database Explorer (panel izquierdo). Haz clic en el ícono de suma + (New) > Data Source > PostgreSQL. En la ventana de configuración del Data Source, ingresa las siguientes credenciales: Host: localhost Port: 5432 User: postgres (usuario por defecto del contenedor) Password: yourpassword Database: postgres (base de datos por defecto a la que conectarse inicialmente)
(Importante) Si en la parte inferior aparece un aviso de Driver files are missing, haz clic en el enlace Download para que DataGrip obtenga el driver de conexión necesario.
Haz clic en Test Connection para verificar la comunicación con el contenedor. Debería mostrar un mensaje indicando Succeeded. Haz clic en OK o Apply para guardar la conexión.
Crear la Base de Datos desde DataGrip Con la conexión configurada y probada correctamente, es momento de crear la base de datos: En el Database Explorer, haz clic derecho sobre la nueva conexión de PostgreSQL y selecciona New > Query Console. En el editor de texto que se abre, escribe el siguiente comando SQL:
SQL CREATE DATABASE my_first_database WITH TEMPLATE template0; Selecciona la línea y ejecuta el comando presionando el ícono verde de Ejecutar o mediante el atajo de teclado (Ctrl + Enter en Windows/Linux o Cmd + Enter en macOS).
Para visualizar la nueva base de datos, haz clic derecho sobre la conexión en el explorador y selecciona Refresh.
