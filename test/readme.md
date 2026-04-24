--los scrip se deben ejecutar de en el mismo orden en el que se ejecutan los archivos del codigo completo, se ejecuta todo el codigo  y luego en el mismo orden ejecutar los scrip que estan en el archivo scrip.md dentro de la carpeta test, primero la creacion de la tabla, luego la funcion, luego el triggers y por ultimo la vista.

functions.sql y triggers.sql deben ejecutarse como script completo (Alt+X en DBeaver), no por fragmentos, porque usan DELIMITER en el codigo completo, los que se encuetran dentro de la carpeta de test.md estan de manera independiente peor si debeen ser ejecutados en el mismo orden que se hizo laa ejecucion dle codigo completo.

```sql
SOURCE database.sql;
SOURCE functions.sql;
SOURCE triggers.sql;
SOURCE sample_data.sql;
SOURCE views_and_queries.sql;